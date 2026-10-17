# frozen_string_literal: true

class PuppetResults
  def initialize
    @results = []
  end

  def <<(result)
    @results << result
    self
  end

  def each(&block)
    @results.each(&block)
  end

  def length
    @results.length
  end

  def count(&block)
    @results.count(&block)
  end

  def sum(&block)
    @results.sum(&block)
  end
end
