defmodule GuitarNotes.Model.Chord do
  use Ecto.Schema

  alias Ecto.Changeset

  # The 's' stands for sharp
  @notes [
    a: "a",
    as: "a#",
    b: "b",
    c: "c",
    cs: "c#",
    d: "d",
    ds: "d#",
    e: "e",
    f: "f",
    fs: "f#",
    g: "g",
    gs: "g#"
  ]

  @primary_key false
  schema "abstract chord" do
    field(:tonic, Ecto.Enum, values: @notes, null: false)
    field(:third, Ecto.Enum, values: @notes)
    field(:fifth, Ecto.Enum, values: @notes)
  end

  def new(chord \\ %__MODULE__{}, params) do
    fields = __MODULE__.__schema__(:fields)
    required = [:tonic]
    params = Map.new(params)

    chord
    |> Changeset.cast(params, fields)
    |> Changeset.validate_required(required)
    |> Changeset.apply_action(:insert)
  end

  def notes(%__MODULE__{} = chord) do
    Enum.reject([chord.tonic, chord.third, chord.fifth], &is_nil/1)
  end

  def existing_notes(), do: ["a", "as", "b", "c", "cs", "d", "ds", "e", "f", "fs", "g", "gs"]

  @pretty %{
    a: "A",
    as: "A#",
    b: "B",
    c: "C",
    cs: "C#",
    d: "D",
    ds: "D#",
    e: "E",
    f: "F",
    fs: "F#",
    g: "G",
    gs: "G#"
  }
  def pretty(note), do: @pretty[note]
end
