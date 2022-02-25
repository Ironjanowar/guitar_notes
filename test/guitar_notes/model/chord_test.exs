defmodule GuitarNotes.Model.ChordTest do
  use GuitarNotes.DataCase, async: true

  alias GuitarNotes.Model.Chord

  test "new/2" do
    assert {:ok, %Chord{tonic: :e}} = Chord.new(tonic: :e)
    assert {:ok, %Chord{tonic: :e}} = Chord.new(%{"tonic" => "e"})

    assert {:ok, chord} = Chord.new(%{"tonic" => "e", "third" => "c", "fifth" => "g"})
    assert %Chord{tonic: :e, third: :c, fifth: :g} = chord

    # Also updates chords
    assert {:ok, chord} = Chord.new(tonic: :e)
    assert {:ok, chord} = Chord.new(chord, tonic: :d)
    assert %Chord{tonic: :d} = chord

    assert {:ok, chord} = Chord.new(tonic: :e, third: :c, fifth: :g)
    assert %Chord{tonic: :e, third: :c, fifth: :g} = chord
    assert {:ok, %Chord{tonic: :e, third: :d, fifth: :g}} = Chord.new(chord, third: :d)
  end
end
