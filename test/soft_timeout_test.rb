require 'test_helper'

class SoftTimeoutTest < Minitest::Test
  def setup
    @soft_timeout = SoftTimeout::Timeout.new(1,3) do
      print 'print on soft timeout'
    end
  end

  def test_that_it_has_a_version_number
    refute_nil ::SoftTimeout::VERSION
  end

  def test_soft_timeout_initialize
    assert_equal @soft_timeout.soft_expiry, 1
    assert_equal @soft_timeout.hard_expiry, 3
    assert_equal @soft_timeout.error_class, nil
  end

  def test_should_execute_soft_timeout_proc
    out, err = capture_io do
      @soft_timeout.soft_timeout{ sleep(2)}
    end
    assert_equal "print on soft timeout", out
  end


  def test_should_not_execute_soft_timeout_proc
    out, err = capture_io do
      @soft_timeout.soft_timeout{ sleep(1)}
    end
    assert_equal '', out
  end

  def test_should_raise_error
    assert_raises ::Timeout::Error do
      @soft_timeout.soft_timeout{ sleep(4)}
    end
  end
end
