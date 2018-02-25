# Rob Fors
# 20160105
# core extensions I found useful

class Object
  def not_nil?
    !nil?
  end

  def as
    yield self
  end
  
  def true?
    self == true
  end
  
  def false?
    self == false
  end
  
  def is_not_a? klass
    !is_a?(klass)
  end
  
  def in?(arg)
    arg.include?(self)
  end
  
  def one_of?(*args)
    args.include?(self)
  end
  
end


class Numeric
  def positive?
    self > 0
  end

  def negative?
    self < 0
  end
end


class Array
  def uniq?
    length == uniq.length
  end
  
  def to_h
    Hash[self]
  end
  
  def swap_indexes(a,b)
    temp = self.dup
    temp[a], temp[b] = temp[b], temp[a]
    temp
  end
  
  def swap_indexes!(a,b)
    self[a], self[b] = self[b], self[a]
    self
  end
end

module Enumerable
  def exclude?(element)
    !include?(element)
  end
  
  def find_element(element)
    find { |i| i == element }
  end
end


class Hash
  def + (otherHash)
    merge(otherHash) { |key, v1, v2| [v1,v2] }
  end
  
  def consolidate(otherHash)
    (keys + otherHash.keys).map { |key| [key, [self[key], otherHash[key]]] }.to_h
  end
  
  def include_hash?(other)
    other.all? do |other_key_value|
      any? { |own_key_value| own_key_value == other_key_value }
    end
  end
  
  def symbolize_keys
    self.map { |k,v| [k.to_sym, v] }.to_h
  end
  
  def symbolize_keys!
    self.map! { |k,v| [k.to_sym, v] }.to_h
  end
end


class File
  def self.append(path, text)
    open(path, 'a') { |f| f.write text }
  end

  def self.append_line(path, text)
    open(path, 'a') do |f|
      f.write(text)
      f.puts
    end
  end
  
  def self.shared_read(path)
    open(path, 'r') do |f|
      f.flock(File::LOCK_SH)
      f.read
    end
  end
  
  def self.exclusive_read(path)
    open(path, 'r') do |f|
      f.flock(File::LOCK_EX)
      f.read
    end
  end

  def self.exclusive_write(path, string)
    open(path, 'a+') do |f|
      f.flock(File::LOCK_EX)
      f.rewind
      f.write(string)
      f.flush
      f.truncate(f.pos)
    end
  end
  
  def self.exclusive_modify(path)
    open(path, 'a+') do |f|
      f.flock(File::LOCK_EX)
      f.rewind
      string = yield f.read
      f.rewind
      f.write(string)
      f.flush
      f.truncate(f.pos)
    end
  end
  
  def self.exclusive_append(path)
    open(path, 'a+') do |f|
      f.flock(File::LOCK_EX)
      f.rewind
      string = yield f.read
      f.write(string)
      f.flush
      f.truncate(f.pos)
    end
  end
end


class MatchData
  def to_h
    names.zip(captures).to_h
  end
end


class NilClass
  def to_h
    {}
  end
end


module JSON
  def self.validate(string)
    begin
      JSON.parse(string)
      true
    rescue JSON::ParserError => e  
      false
    end
  end
end


class Proc
  def self.to_lambda(block)
    raise 'argument is not a Proc' unless block.is_a?(Proc)
    if RUBY_ENGINE && RUBY_ENGINE == "jruby"
      return lambda(&block)
    else
      obj = Object.new
      obj.define_singleton_method(:_, &block)
      return obj.method(:_).to_proc
    end
  end
  
  def to_lambda
    self.class.to_lambda(self)
  end
end
