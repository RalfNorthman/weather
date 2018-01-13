defmodule Weather.Worker do
  @moduledoc false

  @api_key "PUT-YOUR-API-KEY-HERE"

  def loop do
    receive do
      {sender_pid, location} -> 
        send(sender_pid, {:ok, temperature_of(location)})
      _ ->
        IO.puts "Don't know how to process this message."
    end
    loop
  end

  @spec temperature_of(String.t) :: String.t
  def temperature_of(location) do
    location
    |> make_url
    |> HTTPoison.get
    |> parse_response
    |> fetch_temperature
    |> make_message(location)
  end

  defp make_url(location) do
    location = URI.encode location
    "http://api.apixu.com/v1/current.json?key=#{@api_key}&q=#{location}"
  end

  defp parse_response(httpoison_tuple)
  defp parse_response(
    {:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
      Jason.decode body
    end
  defp parse_response(_), do: :error

  defp fetch_temperature(decoded_json) do
    use OkJose
    decoded_json
    |> Map.fetch("current")
    |> Map.fetch("temp_c")
    |> Pipe.ok
  end

  defp make_message(temp_tuple, location)
  defp make_message({:ok, temp}, location), do: "#{location}: #{temp}°C" 
  defp make_message(_, location),           do: "#{location} not found"  

end
