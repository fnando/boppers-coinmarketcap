# frozen_string_literal: true

require "test_helper"

class BoppersCoinMarketCapTest < Minitest::Test
  setup do
    stub_request(:get, /.+/)
      .to_return(
        status: 200,
        body: File.read("./test/support/response.json"),
        headers: {"Content-Type" => "application/json"}
      )
  end

  test "lints plugin" do
    params = {ticker: "XLM", value: "0.00000405", operator: "less_than"}
    bopper = Boppers::CoinMarketCap.new(**params)
    Boppers::Testing::BopperLinter.call(bopper)
  end

  test "makes request correctly" do
    params = {ticker: "XLM", value: "0.00000405", operator: "less_than"}
    bopper = Boppers::CoinMarketCap.new(params)
    bopper.call

    request = WebMock.requests.last

    assert_equal "https://api.coinmarketcap.com/v1/ticker/?limit=0",
                 request.uri.normalize.to_s
  end

  test "sends notification" do
    call = nil
    title = "[COINMARKETCAP] XLM traded as 0.00000534 ($0.0353091)"
    message = [
      "24h Change: 14.46%",
      "Volume: $15085600.0",
      "Market Cap: $585725172.0",
      "",
      "https://coinmarketcap.com/currencies/stellar/"
    ].join("\n")

    Boppers
      .expects(:notify)
      .with do |*args|
        call = args
      end
      .once

    params = {ticker: "XLM", value: "0.00000600", operator: "less_than"}
    bopper = Boppers::CoinMarketCap.new(params)
    bopper.call

    assert_equal :coinmarketcap, call.first
    assert_equal title, call.last[:title]
    assert_equal message, call.last[:message]
    assert_equal "<b>#{title}</b>", call.last.dig(:options, :telegram, :title)
    assert_equal "HTML", call.last.dig(:options, :telegram, :parse_mode)
    assert call.last.dig(:options, :telegram, :disable_web_page_preview)
  end

  test "notifies only once (less_than operator)" do
    Boppers.expects(:notify).once
    params = {ticker: "XLM", value: "0.00000700", operator: "less_than"}
    bopper = Boppers::CoinMarketCap.new(params)

    bopper.call
    bopper.call
  end

  test "notifies using USD (less_than operator)" do
    Boppers.expects(:notify).once
    params = {ticker: "XLM", value: "0.0353092", operator: "less_than"}
    bopper = Boppers::CoinMarketCap.new(params)

    bopper.call
    bopper.call
  end

  test "notifies using USD (greater_than operator)" do
    Boppers.expects(:notify).once
    params = {ticker: "XLM", value: "0.0353090", operator: "less_than"}
    bopper = Boppers::CoinMarketCap.new(params)

    bopper.call
    bopper.call
  end

  test "notifies only once (greater_than operator)" do
    Boppers.expects(:notify).once
    params = {ticker: "XLM", value: "0.00000433", operator: "greater_than"}
    bopper = Boppers::CoinMarketCap.new(params)

    bopper.call
    bopper.call
  end

  test "resends notification after price changing (less_than operator)" do
    expected_titles = [
      "[COINMARKETCAP] XLM traded as 0.00000534 ($0.0353091)",
      "[COINMARKETCAP] XLM traded as 0.00000530 ($0.0353091)"
    ]

    payload = JSON.parse(File.read("./test/support/response.json"))
                  .find {|ticker| ticker["symbol"] == "XLM" }

    response1 = {
      status: 200,
      body: JSON.dump([payload]),
      headers: {"Content-Type" => "application/json"}
    }

    payload["price_btc"] = "0.00000535"
    response2 = {
      status: 200,
      body: JSON.dump([payload]),
      headers: {"Content-Type" => "application/json"}
    }

    payload["price_btc"] = "0.00000530"
    response3 = {
      status: 200,
      body: JSON.dump([payload]),
      headers: {"Content-Type" => "application/json"}
    }

    stub_request(:get, /.+/)
      .to_return(response1, response2, response3)

    Boppers.expects(:notify).twice.with do |_, kwargs|
      expected_titles.shift == kwargs[:title]
    end

    params = {ticker: "XLM", value: "0.00000535", operator: "less_than"}
    bopper = Boppers::CoinMarketCap.new(params)

    bopper.call
    bopper.call
    bopper.call
  end

  test "resends notification after price changing (greater_than operator)" do
    expected_titles = [
      "[COINMARKETCAP] XLM traded as 0.00000534 ($0.0353091)",
      "[COINMARKETCAP] XLM traded as 0.00000537 ($0.0353091)"
    ]

    payload = JSON.parse(File.read("./test/support/response.json"))
                  .find {|ticker| ticker["symbol"] == "XLM" }

    response1 = {
      status: 200,
      body: JSON.dump([payload]),
      headers: {"Content-Type" => "application/json"}
    }

    payload["price_btc"] = "0.00000530"
    response2 = {
      status: 200,
      body: JSON.dump([payload]),
      headers: {"Content-Type" => "application/json"}
    }

    payload["price_btc"] = "0.00000537"
    response3 = {
      status: 200,
      body: JSON.dump([payload]),
      headers: {"Content-Type" => "application/json"}
    }

    stub_request(:get, /.+/)
      .to_return(response1, response2, response3)

    Boppers.expects(:notify).twice.with do |_, kwargs|
      expected_titles.shift == kwargs[:title]
    end

    params = {ticker: "XLM", value: "0.00000533", operator: "greater_than"}
    bopper = Boppers::CoinMarketCap.new(params)

    bopper.call
    bopper.call
    bopper.call
  end
end
