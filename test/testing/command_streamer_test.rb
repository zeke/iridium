require 'test_helper'
require 'shellwords'

class CommandStreamerTest < MiniTest::Unit::TestCase
  def test_nothing_is_raised_when_command_works
    command = Iridium::Testing::CommandStreamer.new "ls"
    command.run
  end

  def test_raises_an_error_when_command_fails
    script_path = File.expand_path "../../script/fail", __FILE__

    command = Iridium::Testing::CommandStreamer.new script_path

    assert_raises Iridium::Testing::CommandStreamer::CommandFailed do
      command.run
    end
  end

  def test_survives_when_command_cannot_be_found
    command = Iridium::Testing::CommandStreamer.new "asdfoijdafkdasjf"

    assert_raises Iridium::Testing::CommandStreamer::CommandFailed do
      command.run
    end
  end

  def test_passes_message_back_to_iridium
    json = { :foo => :bar }.to_json
    collector = []

    command = Iridium::Testing::CommandStreamer.new "echo #{Shellwords.shellescape(json)}"
    command.run do |message|
      collector << message
    end

    assert_equal 1, collector.size
    assert_equal({
      "foo" => "bar"
    }, collector.first)
  end

  def test_raises_an_error_when_process_sends_an_abort_signal
    json = {:signal => 'abort', :data => "Failed"}.to_json

    command = Iridium::Testing::CommandStreamer.new "echo #{Shellwords.shellescape(json)}"

    assert_raises Iridium::Testing::CommandStreamer::ProcessAborted do
      command.run
    end
  end
end
