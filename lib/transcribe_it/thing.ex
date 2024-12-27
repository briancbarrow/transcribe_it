defmodule TranscribeIt.Thing do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :audio_upload, :string
  end

  def changeset(thing, attrs) do
    thing
    |> cast(attrs, [:audio_upload])
    |> validate_required([:audio_upload])
  end
end
