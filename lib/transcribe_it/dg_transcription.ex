defmodule TranscribeIt.DgTranscription do

  def transcribe_audio(file_path, content_type) do
    IO.inspect(file_path, label: "file_path")

    headers = [
      {"Authorization", "Token #{@api_key}"},
      {"Content-Type", content_type}
    ]

    options = [
      recv_timeout: 300_000,
      timeout: 300_000
    ]

    case File.read(file_path) do
      {:ok, audio_data} ->
        IO.inspect(audio_data, lable: "audio_data")
        response = HTTPoison.post(@api_url, audio_data, headers, options)

        case response do
          {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
            {:ok, parse_transcription(body)}

          {:ok, %HTTPoison.Response{status_code: status_code}} ->
            IO.puts("Failed to get transcription. Status code: #{status_code}")
            {:error, "Failed to get transcription. Status code: #{status_code}"}

          {:error, %HTTPoison.Error{reason: reason}} ->
            IO.puts("HTTP request failed: #{reason}")
            {:error, "Failed to get transcription. Status code: #{reason}"}
        end

      {:error, reason} ->
        IO.puts("Failed to read audio file: #{reason}")
    end
  end

  defp parse_transcription(body) do
    case Jason.decode(body) do
      {:ok, decoded_body} ->
        %{
          "results" => %{
            "channels" => [
              %{"alternatives" => [%{"paragraphs" => %{"transcript" => transcript}}]}
            ]
          }
        } =
          decoded_body

        {:ok, transcript}

      {:error, reason} ->
        {:error, reason}
    end
  end

  # defp save_transcription(transcription, output_path) do
  #   File.write(output_path, transcription)
  #   IO.puts("Transcription saved to transcription.txt")
  # end
end
