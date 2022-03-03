defmodule GuitarNotesWeb.GuitarLive do
  use Phoenix.LiveView

  alias GuitarNotesWeb.Components.{ChordSelectorComponent, StringComponent}
  alias GuitarNotes.ChordBuilder, as: Builder
  alias GuitarNotes.Model.Chord

  @notes Chord.existing_notes()

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

    {:ok, chord} = Builder.build(:e, third: :min, fifth: :perfect)
    chords = [chord]
    chord_notes = chords |> Enum.flat_map(&Chord.notes/1) |> Enum.uniq()
    chords_order = Enum.map(chords, & &1.tonic)
    chords = Map.new(chords, &{&1.tonic, &1})

    {:ok,
     assign(socket,
       configs: configs,
       chord_notes: chord_notes,
       chords: chords,
       chords_order: chords_order
     )}
  end

  def handle_event("chord_change", params, socket) do
    if valid_change?(params) do
      do_update_chord(params, socket)
    else
      {:noreply, socket}
    end
  end

  def handle_event("add_chord", _params, socket) do
    chords = socket.assigns.chords
    current_notes = Enum.map(chords, fn {note, _} -> to_string(note) end)
    available_notes = @notes -- current_notes

    new_note = Enum.random(available_notes) |> String.to_existing_atom()

    {:ok, chord} = Builder.build(new_note, third: :maj, fifth: :perfect)
    chords = Map.put(chords, new_note, chord)
    chord_notes = chords |> Enum.flat_map(fn {_, chord} -> Chord.notes(chord) end) |> Enum.uniq()
    chords_order = socket.assigns.chords_order ++ [new_note]

    {:noreply,
     assign(socket, chord_notes: chord_notes, chords: chords, chords_order: chords_order)}
  end

  def handle_event("nothing", _params, socket) do
    {:noreply, socket}
  end

  defp valid_change?(%{"chord" => changes}) do
    Enum.all?(changes, fn
      {note, ""} when note in @notes -> false
      _ -> true
    end)
  end

  defp do_update_chord(params, socket) do
    chords = socket.assigns.chords

    {old_tonic, old_tonic_str} = get_old_tonic(params["_target"])
    new_tonic = params["chord"][old_tonic_str] |> String.downcase() |> String.to_existing_atom()

    chords =
      if update_chord?(params["_target"]) do
        update_old_chord(params, chords)
      else
        update_intervals(params, chords)
      end

    chord_notes = chords |> Enum.flat_map(fn {_, chord} -> Chord.notes(chord) end) |> Enum.uniq()

    chords_order =
      Enum.map(socket.assigns.chords_order, fn note ->
        if note == old_tonic do
          new_tonic
        else
          note
        end
      end)

    {:noreply,
     assign(socket, chords: chords, chord_notes: chord_notes, chords_order: chords_order)}
  end

  defp update_chord?([_, tonic]) when tonic in @notes, do: true
  defp update_chord?(_), do: false

  defp update_intervals(params, chords) do
    {changes, tonic_change} = Map.split(params["chord"], ["third", "fifth"])

    tonic =
      tonic_change
      |> Enum.find(fn {note, _} -> note in @notes end)
      |> elem(0)
      |> String.to_existing_atom()

    Map.update!(chords, tonic, fn chord ->
      {:ok, chord} = Builder.build(chord, changes)
      chord
    end)
  end

  defp update_old_chord(params, chords) do
    # Pop old chord
    {old_tonic, old_tonic_str} = get_old_tonic(params["_target"])
    {old_chord, chords} = Map.pop(chords, old_tonic)

    # Update old chord
    {changes, _} = Map.split(params["chord"], ["third", "fifth"])
    new_tonic = params["chord"][old_tonic_str] |> String.downcase() |> String.to_existing_atom()
    new_chord = update_old_chord(old_chord, new_tonic, changes)

    # Insert new chord
    Map.put(chords, new_tonic, new_chord)
  end

  defp get_old_tonic([_, tonic]), do: {String.to_existing_atom(tonic), tonic}

  defp update_old_chord(old_chord, new_tonic, changes) do
    with {:ok, chord} <- Chord.new(old_chord, tonic: new_tonic),
         {:ok, chord} <- Builder.build(chord, changes) do
      chord
    else
      error -> raise "Could not update old chord: #{inspect(error)}"
    end
  end
end
