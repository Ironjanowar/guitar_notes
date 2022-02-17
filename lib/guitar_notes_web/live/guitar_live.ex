defmodule GuitarNotesWeb.GuitarLive do
  use Phoenix.LiveView

  alias GuitarNotesWeb.Components.StringComponent
  alias GuitarNotes.ChordBuilder, as: Builder
  alias GuitarNotes.Model.Chord

  def mount(_params, _session, socket) do
    # TODO: this is standard tunning only
    configs = [
      %{note: :e, id: Ecto.UUID.generate()},
      %{note: :b, id: Ecto.UUID.generate()},
      %{note: :g, id: Ecto.UUID.generate()},
      %{note: :d, id: Ecto.UUID.generate()},
      %{note: :a, id: Ecto.UUID.generate()},
      %{note: :e, id: Ecto.UUID.generate()}
    ]

    {:ok, chord} = Builder.build(:c, third: :maj, fifth: :perfect)
    chord_notes = Chord.notes(chord)

    {:ok, assign(socket, configs: configs, chord_notes: chord_notes)}
  end
end
