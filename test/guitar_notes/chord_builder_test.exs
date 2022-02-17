defmodule GuitarNotes.ChordBuilderTest do
  use GuitarNotes.DataCase, async: true

  alias GuitarNotes.ChordBuilder, as: Builder
  alias GuitarNotes.Model.Chord

  test "build/2" do
    assert {:ok, %Chord{tonic: :c, third: :e}} = Builder.build(:c, third: :maj)
    assert {:ok, %Chord{tonic: :c, third: :ds}} = Builder.build(:c, third: :min)
    assert {:ok, %Chord{tonic: :c, fifth: :fs}} = Builder.build(:c, fifth: :diminished)
    assert {:ok, %Chord{tonic: :c, fifth: :g}} = Builder.build(:c, fifth: :perfect)
    assert {:ok, %Chord{tonic: :c, fifth: :gs}} = Builder.build(:c, fifth: :augmented)

    intervals = [third: :maj, fifth: :perfect]
    assert {:ok, %Chord{tonic: :c, third: :e, fifth: :g}} = Builder.build(:c, intervals)

    assert {:error, "Unknown interval :unknown :interval"} = Builder.build(:c, unknown: :interval)
  end

  test "calculate_interval/2" do
    assert {:ok, :d} = Builder.calculate_interval(:c, 2)
    assert {:ok, :ds} = Builder.calculate_interval(:c, 3)

    # Octave
    assert {:ok, :c} = Builder.calculate_interval(:c, 12)

    # Over 12 intervals
    assert {:ok, :cs} = Builder.calculate_interval(:c, 13)
    assert {:ok, :ds} = Builder.calculate_interval(:c, 15)

    # Negative intervals
    assert {:ok, :b} = Builder.calculate_interval(:c, -1)
    assert {:ok, :a} = Builder.calculate_interval(:c, -3)

    # Really negative intervals
    assert {:ok, :b} = Builder.calculate_interval(:c, -13)
    assert {:ok, :a} = Builder.calculate_interval(:c, -15)
  end
end