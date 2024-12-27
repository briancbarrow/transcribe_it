defmodule TranscribeItWeb.ThingLive do
  alias TranscribeIt.Thing
  alias TranscribeIt.DgTranscription
  use TranscribeItWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign_thing()
     |> clear_form()
     |> allow_upload(:audio,
       accept: ~w(.wav .mp3),
       max_entries: 1,
       max_file_size: 100_000_000,
       auto_upload: true
     )}
  end

  def assign_thing(socket) do
    socket
    |> assign(:thing, %Thing{})
    |> assign(:transcript, "")
  end

  def assign_form(socket, changeset) do
    assign(socket, :form, to_form(changeset))
  end

  def clear_form(socket) do
    form =
      socket.assigns.thing
      |> Thing.changeset(%{})
      |> to_form()

    assign(socket, form: form)
  end

  def get_transcript(socket, params) do
    IO.inspect(params, label: "params")

    transcript =
      socket
      |> consume_uploaded_entries(:audio, fn %{path: path}, entry ->
        IO.inspect(entry, label: "entry")

        DgTranscription.transcribe_audio(path, entry.client_type)
      end)
      |> List.first()

    IO.inspect(transcript, label: "Test hwew")
    transcript
  end

  defp upload_static_file(%{path: path, client_type: client_type}, _entry) do
    IO.inspect(path, label: "upload func path")
    # filename = Path.basename(path)
    # dest = Path.join("priv/static/audio", filename)
    # File.cp!(path, dest)
    DgTranscription.transcribe_audio(path, client_type)
  end

  def handle_event("validate", unsigned_params, socket) do
    IO.inspect(unsigned_params, label: "unsigned_params")
    {:noreply, socket}
  end

  def handle_event("submit", params, socket) do
    case get_transcript(socket, params) do
      {:ok, transcript} ->
        IO.inspect(transcript, label: "TRANSCRIPT")

        {:noreply,
         socket
         |> put_flash(:info, "Transcription generated")
         |> assign(transcript: transcript)}

      {:error, reason} ->
        IO.inspect("GOT HERE error")

        {:noreply, socket |> put_flash(:error, "Error retrieving transcript: #{reason}")}

      _ ->
        IO.inspect("GOT HERE nil")

        {:noreply, socket |> put_flash(:error, "Error getting transcript")}
    end
  end
end
