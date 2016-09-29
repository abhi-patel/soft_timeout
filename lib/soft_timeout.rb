require "soft_timeout/version"
require 'timeout'
module SoftTimeout

  THIS_FILE = /\A#{Regexp.quote(__FILE__)}:/o
  CALLER_OFFSET = ((c = caller[0]) && THIS_FILE =~ c) ? 1 : 0
  private_constant :THIS_FILE, :CALLER_OFFSET

  # require 'soft_timeout'
  #
  # timeout = SoftTimeout::Timeout.new(10, 20) do
  #   puts 'Soft timeout reached'
  # end
  #
  # timeout.soft_timeout do
  #   ...
  #   Some code
  #   ...
  # end
  class Timeout
    attr_accessor :soft_expiry, :hard_expiry, :error_class, :on_soft_timeout

    # Initialize
    #
    # +soft_expiry+:: Number of seconds to wait to execute +on_soft_timeout+ block
    # +hard_expiry+:: Number of seconds to wait before raising Timeout Error
    # +error_class+:: Exception class to raise
    # +block+:: Proc to be run at end of +soft_expiry+
    #
    def initialize(soft_expiry, hard_expiry, error_class = nil, &block)
      self.soft_expiry = soft_expiry
      self.hard_expiry = hard_expiry
      self.error_class = error_class
      self.on_soft_timeout = block if block_given?
    end

    def soft_timeout
      return yield(soft_expiry) if soft_expiry == nil || soft_expiry < 0 || hard_expiry == nil || hard_expiry < 0 || hard_expiry <= soft_expiry
      message = "execution expired".freeze

      e = ::Timeout::Error
      bl = proc do |exception|
        begin
          original_thread = Thread.current
          timeout_thread = Thread.start {
            begin
              sleep soft_expiry
            rescue => e
              original_thread.raise e
            else
              on_soft_timeout.call if on_soft_timeout
            end

            begin
              sleep hard_expiry - soft_expiry
            rescue => e
              original_thread.raise e
            else
              original_thread.raise exception, message
            end
          }
          return yield(soft_expiry)
        ensure
          if timeout_thread
            timeout_thread.kill
            timeout_thread.join # make sure timeout_thread is dead.
          end
        end
      end

      # Why this strange Error catch and all. checkout http://stackoverflow.com/questions/35447230/ruby-timeout-behaves-differently-between-2-0-and-2-1
      if error_class
        begin
          bl.call(error_class)
        rescue error_class => l
          bt = l.backtrace
        end
      else
        bt = ::Timeout::Error.catch(message, &bl)
      end


      level = -caller(CALLER_OFFSET).size-2
      while THIS_FILE =~ bt[level]
        bt.delete_at(level)
      end
      raise(e, message, bt)
    end

  end
end
