require File.dirname(__FILE__) + '/../test_helper'
require 'favorites_mailer'

class FavoritesMailerTest < Test::Unit::TestCase
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"

  include ActionMailer::Quoting

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @expected = TMail::Mail.new
    @expected.set_content_type "text", "plain", { "charset" => CHARSET }
  end

  def test_favorites_update
    @expected.subject = 'FavoritesMailer#favorites_update'
    @expected.body    = read_fixture('favorites_update')
    @expected.date    = Time.now

    #assert_equal @expected.encoded, FavoritesMailer.create_favorites_update(@expected.date).encoded
  end

  private
    def read_fixture(action)
      IO.readlines("#{FIXTURES_PATH}/favorites_mailer/#{action}")
    end

    def encode(subject)
      quoted_printable(subject, CHARSET)
    end
end
