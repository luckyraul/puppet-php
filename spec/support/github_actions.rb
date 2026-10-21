# frozen_string_literal: true

class GitHubActions
  def initialize(output: $stdout)
    @output = output
  end

  def notice(message)
    command('notice', message)
  end

  def warning(message)
    command('warning', message)
  end

  def error(message)
    command('error', message)
  end

  def start_group(title)
    @output.write("::group::#{escape(title)}\n")
  end

  def end_group
    @output.write("::endgroup::\n")
  end

  def group(title)
    start_group(title)
    yield
  ensure
    end_group
  end

  private

  def command(name, message)
    @output.write("::#{name}::#{escape(message)}\n")
  end

  def escape(value)
    value.to_s
         .gsub('%', '%25')
         .gsub("\r", '%0D')
         .gsub("\n", '%0A')
  end
end
