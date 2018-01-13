defmodule Weather.Worker do
  @moduledoc false

  use GenServer

  @api_key "PUT-YOUR-API-KEY-HERE"

  ## Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def get_temperature(pid, location) do
    GenServer.call(pid, {:location, location})
  end

  def get_stats(pid) do
    GenServer.call(pid, :get_stats)
  end

  ## Server Callbacks

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:location, location}, _from, stats) do
    case temperature_of(location) do
      {:ok, temp} ->
        new_stats = update_stats(stats, location)
        {:reply, "#{location}: #{temp}°C", new_stats}
      _ -> 
        {:reply, :error, stats}
    end
  end
  def handle_call(:get_stats, _from, stats) do
    {:reply, stats, stats}
  end

  ## Helper Functions

  @spec temperature_of(String.t) :: String.t
  def temperature_of(location) do
    location
    |> make_url
    |> HTTPoison.get
    |> parse_response
    |> fetch_temperature
  end

  defp make_url(location) do
    location = URI.encode location
    "http://api.apixu.com/v1/current.json?key=#{@api_key}&q=#{location}"
  end

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

  defp update_stats(old_stats, location) do
    if Map.has_key?(old_stats, location) do
      Map.update!(old_stats, location, &(&1 + 1))
    else
      Map.put_new(old_stats, location, 1)
    end
  end

end
