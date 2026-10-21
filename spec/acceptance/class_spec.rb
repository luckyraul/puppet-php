# frozen_string_literal: true

require 'docker'
require 'serverspec'
require 'logger'
require 'yaml'

require_relative '../support/github_actions'
require_relative '../support/puppet_results'

Docker.options[:read_timeout] = 300
Docker.options[:write_timeout] = 300

LOGGER = Logger.new($stdout)
LOGGER.level = Logger::INFO
LOGGER.formatter = proc do |_severity, _datetime, _progname, message|
  "#{message}\n"
end

GITHUB_ACTIONS = GitHubActions.new
PUPPET_RESULTS = PuppetResults.new

def strip_ansi_codes(string)
  string.gsub(%r{\e\[[\d;]*m}, '')
end

def github_summary_available?
  path = github_summary_path
  path && !path.empty?
end

def github_group(title, &block)
  GITHUB_ACTIONS.group(title, &block)
end

def github_notice(message)
  GITHUB_ACTIONS.notice(message)
end

def github_warning(message)
  GITHUB_ACTIONS.warning(message)
end

def github_error(message)
  GITHUB_ACTIONS.error(message)
end

def current_rspec_context
  example = RSpec.current_example
  return 'Unknown context' unless example

  example.example_group.parent_groups
         .map(&:description)
         .reverse
         .join(' › ')
end

def current_rspec_example
  RSpec.current_example&.description || 'Unknown example'
end

def clean_command_output(output)
  strip_ansi_codes(Array(output).join).gsub("\r\n", "\n")
end

def log_puppet_output(title, output)
  return if output.empty?

  github_group(title) do
    output.each_line do |line|
      line = line.chomp
      next if line.empty?

      case line
      when %r{\AWarning:}
        github_warning(line)
        LOGGER.warn(line)
      when %r{\AError:}
        github_error(line)
        LOGGER.error(line)
      else
        LOGGER.info(line)
      end
    end
  end
end

def write_github_summary
  LOGGER.info('write summary')
  path = ENV.fetch('GITHUB_STEP_SUMMARY', nil)
  return unless path && !path.empty?

  total = PUPPET_RESULTS.length
  successful = PUPPET_RESULTS.count { |result| result[:success] }
  failed = total - successful
  changed = PUPPET_RESULTS.count { |result| result[:exit_code] == 2 }
  duration = PUPPET_RESULTS.sum { |result| result[:duration] }

  status = failed.zero? ? 'Passed' : 'Failed'

  summary = <<~MARKDOWN
    ## 📊 Puppet Acceptance Test Summary

    | Metric | Result |
    |:--|--:|
    | Status | **#{status}** |
    | Manifest applications | #{total} |
    | Successful applications | #{successful} |
    | Failed applications | #{failed} |
    | Applications with changes | #{changed} |
    | Total execution time | #{format('%.2f', duration)} seconds |
  MARKDOWN

  File.open(path, 'a') do |file|
    file.write(summary)
    file.write("\n")
  end
end

def apply_manifest(container, manifest, hiera = {}, exit_codes = [0, 2])
  github_group('📄 Manifest') do
    LOGGER.info(manifest)
  end

  container.store_file('/manifest.pp', manifest)

  command = [
    'puppet',
    'apply',
    '--verbose',
    '--detailed-exitcodes',
  ]

  unless hiera.empty?
    hiera_config = {
      'version' => 5,
      'defaults' => {
        'datadir' => '/opt/',
        'data_hash' => 'yaml_data',
      },
      'hierarchy' => [
        {
          'name' => 'Common',
          'path' => 'common.yaml',
        },
      ],
    }

    container.store_file('/hiera.yaml', hiera_config.to_yaml)
    container.store_file('/opt/common.yaml', hiera.to_yaml)

    command.push('--hiera_config', '/hiera.yaml')

    github_group('⚙️ Hiera configuration') do
      LOGGER.info(hiera.to_yaml)
    end
  end

  command.push('/manifest.pp')

  exit_code = nil
  duration = 0.0
  result_recorded = false

  begin
    started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    begin
      result = container.exec(command, tty: true)
    ensure
      duration =
        Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at
    end

    stdout_clean = clean_command_output(result[0])
    stderr_clean = clean_command_output(result[1])
    exit_code = result[2]

    LOGGER.info("Duration: #{format('%.2f', duration)}s")
    LOGGER.info("Exit code: #{exit_code}")

    log_puppet_output('📄 Puppet stdout', stdout_clean)
    log_puppet_output('⚠️ Puppet stderr', stderr_clean)

    success = exit_codes.include?(exit_code)

    PUPPET_RESULTS << {
      exit_code: exit_code,
      duration: duration,
      success: success,
    }
    result_recorded = true

    unless success
      message = "Puppet apply failed with exit code #{exit_code}"
      github_error(message)
      LOGGER.error(message)
      raise message
    end

    case exit_code
    when 0
      LOGGER.info('✅ No changes needed')
    when 2
      LOGGER.info('🔄 Changes applied')
    else
      LOGGER.info("⚠️ Accepted exit code: #{exit_code}")
    end

    nil
  rescue StandardError => e
    unless result_recorded
      PUPPET_RESULTS << {
        exit_code: exit_code,
        duration: duration,
        success: false,
      }
    end

    github_error("#{e.class}: #{e.message}")
    raise
  end
end

RSpec.configure do |config|
  config.before do |example|
    LOGGER.info('')
    LOGGER.info("🚀 #{current_rspec_context} › #{example.description}")
  end

  config.after do |example|
    status = example.exception ? '❌ FAILED' : '✅ PASSED'
    LOGGER.info("#{status}: #{example.description}")
    LOGGER.info('')
  end
end

at_exit do
  write_github_summary
rescue StandardError => e
  LOGGER.error(
    "Failed to write GitHub Actions summary: #{e.class}: #{e.message}",
  )
end

describe 'php class' do
  context 'default parameters' do
    container = nil

    before(:context) do
      container = Docker::Container.create(
        'Image' => "puppet-lab:#{ENV.fetch('GITHUB_RUN_ID', nil)}",
        'HostConfig' => {
          'CgroupnsMode' => 'host',
          'Binds' => ['/sys/fs/cgroup:/sys/fs/cgroup:rw'],
          'Privileged' => true,
        },
        'Volumes' => {
          '/sys/fs/cgroup' => {},
        },
      )

      container.start
      set :backend, :docker
      set :docker_container, container.id
      Specinfra.backend.instance_variable_set(:@container, container)
    end

    after(:context) do
      container&.stop
      container&.delete
    end

    it 'works idempotently with no errors' do
      manifest = 'include php'

      apply_manifest(container, manifest)
      apply_manifest(container, manifest, {}, [0])
    end

    it 'checks container' do
      command_result = command('facter os')

      expect(command_result.exit_status).to eq(0)
      LOGGER.info(command_result.stdout)
    end

    it 'checks if php package is installed' do
      command_result = command('php -v')

      expect(command_result.exit_status).to eq(0)
      expect(command_result.stdout).to match(%r{PHP\s+\d+\.\d+\.\d+})
    end
  end

  context 'php with external repo' do
    container = nil

    before(:context) do
      container = Docker::Container.create(
        'Image' => "puppet-lab:#{ENV.fetch('GITHUB_RUN_ID', nil)}",
        'HostConfig' => {
          'CgroupnsMode' => 'host',
          'Binds' => ['/sys/fs/cgroup:/sys/fs/cgroup:rw'],
          'Privileged' => true,
        },
        'Volumes' => {
          '/sys/fs/cgroup' => {},
        },
      )

      container.start
      set :backend, :docker
      set :docker_container, container.id
      Specinfra.backend.instance_variable_set(:@container, container)
    end

    after(:context) do
      container&.stop
      container&.delete
    end

    it 'works with manage repo' do
      manifest = <<~PUPPET
        class { 'php':
          manage_repos => true,
        }
      PUPPET

      apply_manifest(container, manifest)
    end

    it 'checks if php package is installed' do
      command_result = command('php -v')

      expect(command_result.exit_status).to eq(0)
      expect(command_result.stdout).to match(%r{PHP\s+\d+\.\d+\.\d+})
    end
  end

  context 'php with external repo and newrelic' do
    container = nil

    before(:context) do
      container = Docker::Container.create(
        'Image' => "puppet-lab:#{ENV.fetch('GITHUB_RUN_ID', nil)}",
        'HostConfig' => {
          'CgroupnsMode' => 'host',
          'Binds' => ['/sys/fs/cgroup:/sys/fs/cgroup:rw'],
          'Privileged' => true,
        },
        'Volumes' => {
          '/sys/fs/cgroup' => {},
        },
      )

      container.start
      set :backend, :docker
      set :docker_container, container.id
      Specinfra.backend.instance_variable_set(:@container, container)
    end

    after(:context) do
      container&.stop
      container&.delete
    end

    it 'works with manage repo' do
      manifest = <<~PUPPET
        class { 'php':
          manage_repos => true,
          newrelic => true,
        }
      PUPPET

      apply_manifest(container, manifest)
    end

    it 'checks if php package is installed' do
      command_result = command('php -v')

      expect(command_result.exit_status).to eq(0)
      expect(command_result.stdout).to match(%r{PHP\s+\d+\.\d+\.\d+})
    end
  end

  context 'php fixed version' do
    container = nil

    before(:context) do
      container = Docker::Container.create(
        'Image' => "puppet-lab:#{ENV.fetch('GITHUB_RUN_ID', nil)}",
        'HostConfig' => {
          'CgroupnsMode' => 'host',
          'Binds' => ['/sys/fs/cgroup:/sys/fs/cgroup:rw'],
          'Privileged' => true,
        },
        'Volumes' => {
          '/sys/fs/cgroup' => {},
        },
      )

      container.start
      set :backend, :docker
      set :docker_container, container.id
      Specinfra.backend.instance_variable_set(:@container, container)
    end

    after(:context) do
      container&.stop
      container&.delete
    end

    it 'works with php 8.99' do
      manifest = <<~PUPPET
        class { 'php::globals':
          php_version => '8.99',
        } -> class { 'php':
          manage_repos => true,
        }
      PUPPET

      apply_manifest(container, manifest, {}, [6])
    end

    it 'checks if php package is installed' do
      command_result = command('php -v')

      expect(command_result.exit_status).to eq(127)
    end
  end

  context 'php hiera' do
    container = nil

    before(:context) do
      container = Docker::Container.create(
        'Image' => "puppet-lab:#{ENV.fetch('GITHUB_RUN_ID', nil)}",
        'HostConfig' => {
          'CgroupnsMode' => 'host',
          'Binds' => ['/sys/fs/cgroup:/sys/fs/cgroup:rw'],
          'Privileged' => true,
        },
        'Volumes' => {
          '/sys/fs/cgroup' => {},
        },
      )

      container.start
      set :backend, :docker
      set :docker_container, container.id
      Specinfra.backend.instance_variable_set(:@container, container)
    end

    after(:context) do
      container&.stop
      container&.delete
    end

    it 'works with hiera' do
      manifest = 'include php'
      hiera = {
        'php::manage_repos' => true,
      }

      apply_manifest(container, manifest, hiera)
      apply_manifest(container, manifest, hiera, [0])
    end

    it 'checks if php package is installed' do
      command_result = command('php -v')

      expect(command_result.exit_status).to eq(0)
      expect(command_result.stdout).to match(%r{PHP\s+\d+\.\d+\.\d+})
    end
  end

  context 'php multiple' do
    container = nil

    before(:context) do
      container = Docker::Container.create(
        'Image' => "puppet-lab:#{ENV.fetch('GITHUB_RUN_ID', nil)}",
        'HostConfig' => {
          'CgroupnsMode' => 'host',
          'Binds' => ['/sys/fs/cgroup:/sys/fs/cgroup:rw'],
          'Privileged' => true,
        },
        'Volumes' => {
          '/sys/fs/cgroup' => {},
        },
      )

      container.start
      set :backend, :docker
      set :docker_container, container.id
      Specinfra.backend.instance_variable_set(:@container, container)
    end

    after(:context) do
      container&.stop
      container&.delete
    end

    it 'works with hiera with multiple' do
      manifest = 'include php'
      hiera = {
        'php::manage_repos' => true,
        'php::multi_version' => ['8.1'],
      }

      apply_manifest(container, manifest, hiera)
      apply_manifest(container, manifest, hiera)
    end

    it 'checks if php package is installed' do
      command_result = command('php -v')

      expect(command_result.exit_status).to eq(0)
      expect(command_result.stdout).to match(%r{PHP\s+\d+\.\d+\.\d+})
    end
  end

  context 'php docker image' do
    container = nil

    before(:context) do
      container = Docker::Container.create(
        'Image' => "puppet-lab:#{ENV.fetch('GITHUB_RUN_ID', nil)}",
        'HostConfig' => {
          'CgroupnsMode' => 'host',
          'Binds' => ['/sys/fs/cgroup:/sys/fs/cgroup:rw'],
          'Privileged' => true,
        },
        'Volumes' => {
          '/sys/fs/cgroup' => {},
        },
      )

      container.start
      set :backend, :docker
      set :docker_container, container.id
      Specinfra.backend.instance_variable_set(:@container, container)
    end

    after(:context) do
      container&.stop
      container&.delete
    end

    it 'works with hiera for docker' do
      manifest = 'include php'
      hiera = {
        'php::manage_repos' => true,
        'php::repo_mirror' => true,
        'php::docker' => true,
        'php::packages' => %w[
          mysql
          mbstring
          intl
          curl
          gd
          xsl
          zip
          bcmath
          soap
          imagick
          pgsql
        ],
        'php::fpm_service_ensure' => 'stopped',
        'php::fpm_service_enable' => false,
        'php::settings' => {
          'PHP' => {
            'max_input_vars' => 5000,
          },
        },
        'php::fpm_service_settings' => {
          'daemonize' => 'no',
          'error_log' => '/proc/self/fd/2',
          'pid_file' => 'nil',
        },
        'php::fpm::pools' => {
          'www' => {
            'listen' => '[::]:9000',
            'catch_workers_output' => 'yes',
            'decorate_workers_output' => 'no',
            'access_log' => '/proc/self/fd/2',
            'access_log_format' => '{"@timestamp":"%{literal(\'%\')}{%Y-%m-%dT%H:%M:%S%z}T","remote_addr":"%R","remote_user":"%u","request_method":"%m","request_uri":"%{literal(\'%\')}{REQUEST_URI}e","status":"%s","request_length":"%l","request_time":"%d","http_referrer":"%{literal(\'%\')}{HTTP_REFERER}e","http_user_agent":"%{literal(\'%\')}{HTTP_USER_AGENT}e","http_x_forwarded_for":"%{literal(\'%\')}{HTTP_X_FORWARDED_FOR}e","request_id":"%{literal(\'%\')}{HTTP_X_REQUEST_ID}e","cpu":"%C","memory":"%{literal(\'%\')}{megabytes}MM"}',
            'clear_env' => 'no',
            'php_value' => {
              'memory_limit' => '512M',
              'upload_max_filesize' => '40M',
              'post_max_size' => '42M',
            },
          },
        },
      }

      apply_manifest(container, manifest, hiera)
      apply_manifest(container, manifest, hiera, [0])
    end

    it 'checks if php package is installed' do
      command_result = command('php -v')

      expect(command_result.exit_status).to eq(0)
      expect(command_result.stdout).to match(%r{PHP\s+\d+\.\d+\.\d+})
    end

    it 'checks container' do
      command_result = command('facter os')

      expect(command_result.exit_status).to eq(0)
      LOGGER.info(command_result.stdout)
    end

    it 'checks apt' do
      command_result = command('apt update')

      expect(command_result.exit_status).to eq(0)
      LOGGER.info(command_result.stdout)
    end
  end
end
