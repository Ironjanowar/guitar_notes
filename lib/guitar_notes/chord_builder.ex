defmodule GuitarNotes.ChordBuilder do
  alias GuitarNotes.Model.Chord

  def build(chord_or_tonic, opts \\ [])

  def build(tonic, opts) when is_atom(tonic) do
    with {:ok, chord} <- Chord.new(tonic: tonic) do
      build(chord, opts)
    end
  end

  def build(%Chord{} = chord, opts) do
    opts = normalize_opts(opts)

    with %Chord{} = chord <- Enum.reduce_while(opts, chord, &build_interval/2) do
      {:ok, chord}
    end
  end

  defp normalize_opts(opts) do
    Map.new(opts, fn {k, v} -> {maybe_to_atom(k), maybe_to_atom(v)} end)
  end

  def calculate_interval(note, steps) when is_atom(note) and is_number(steps) do
    with {:ok, number} <- note_to_number(note) do
      steps = mod_of_number(steps)
      # Sum 12 so we can have negative intervals
      number = 12 + number + steps
      new_number = rem(number, 12)
      number_to_note(new_number)
    end
  end

  def get_notes_from(note, n \\ 12) do
    {:ok, start_note} = note_to_number(note)
    end_note = start_note + n

    Enum.map(start_note..end_note, fn number ->
      {:ok, note} = number |> mod_of_number() |> number_to_note()
      note
    end)
  end

  def get_intervals(%Chord{} = chord) do
    third = maybe_interval(chord.tonic, chord.third)
    fifth = maybe_interval(chord.tonic, chord.fifth)

    Enum.reject([third, fifth], &is_nil/1)
  end

  def interval(note1, note2) when is_atom(note1) and is_atom(note2) do
    note1 |> find_interval(note2) |> get_interval_notation()
  end

  defp find_interval(note1, note2), do: find_interval(note1, note2, 0)

  defp find_interval(note1, note2, distance) do
    if next_note(note1) == note2 do
      distance + 1
    else
      note1 |> next_note() |> find_interval(note2, distance + 1)
    end
  end

  defp next_note(:c), do: :cs
  defp next_note(:cs), do: :d
  defp next_note(:d), do: :ds
  defp next_note(:ds), do: :e
  defp next_note(:e), do: :f
  defp next_note(:f), do: :fs
  defp next_note(:fs), do: :g
  defp next_note(:g), do: :gs
  defp next_note(:gs), do: :a
  defp next_note(:a), do: :as
  defp next_note(:as), do: :b
  defp next_note(:b), do: :c

  # Private
  defp maybe_interval(_, nil), do: nil
  defp maybe_interval(tonic, note), do: interval(tonic, note)

  defp build_interval({type, modifier}, chord) do
    with {:ok, interval_number} <- get_interval(type, modifier),
         {:ok, interval_note} <- calculate_interval(chord.tonic, interval_number) do
      {:cont, %{chord | type => interval_note}}
    else
      error -> {:halt, error}
    end
  end

  defp build_interval(interval, _), do: {:halt, {:error, "Unknown interval #{inspect(interval)}"}}

  # TODO: complete all main intervals
  defp get_interval(type, modifier) when is_binary(type) or is_binary(modifier) do
    type = maybe_to_atom(type)
    modifier = maybe_to_atom(modifier)

    get_interval(type, modifier)
  end

  defp get_interval(:third, :min), do: {:ok, 3}
  defp get_interval(:third, :maj), do: {:ok, 4}
  defp get_interval(:fifth, :diminished), do: {:ok, 6}
  defp get_interval(:fifth, :perfect), do: {:ok, 7}
  defp get_interval(:fifth, :augmented), do: {:ok, 8}

  defp get_interval(type, modifier),
    do: {:error, "Unknown interval #{inspect(type)} #{inspect(modifier)}"}

  defp get_interval_notation(3), do: {:third, :min}
  defp get_interval_notation(4), do: {:third, :maj}
  defp get_interval_notation(6), do: {:fifth, :diminished}
  defp get_interval_notation(7), do: {:fifth, :perfect}
  defp get_interval_notation(8), do: {:fifth, :augmented}

  defp maybe_to_atom(atom) when is_atom(atom), do: atom
  defp maybe_to_atom(str) when is_binary(str), do: String.to_existing_atom(str)

  @numbers_to_notes %{
    0 => :c,
    1 => :cs,
    2 => :d,
    3 => :ds,
    4 => :e,
    5 => :f,
    6 => :fs,
    7 => :g,
    8 => :gs,
    9 => :a,
    10 => :as,
    11 => :b
  }

  @notes_to_numbers %{
    :c => 0,
    :cs => 1,
    :d => 2,
    :ds => 3,
    :e => 4,
    :f => 5,
    :fs => 6,
    :g => 7,
    :gs => 8,
    :a => 9,
    :as => 10,
    :b => 11
  }

  defp note_to_number(note) when is_atom(note) do
    case @notes_to_numbers[note] do
      nil -> {:error, "#{inspect(note)} is not a valid note"}
      number -> {:ok, number}
    end
  end

  defp number_to_note(number) when is_number(number) do
    case @numbers_to_notes[number] do
      nil -> {:error, "#{inspect(number)} is not a valid number for a note"}
      note -> {:ok, note}
    end
  end

  defp mod_of_number(number) when number < 0 do
    abs_number = abs(number)
    number = rem(abs_number, 12)
    number * -1
  end

  defp mod_of_number(number), do: rem(number, 12)
end
