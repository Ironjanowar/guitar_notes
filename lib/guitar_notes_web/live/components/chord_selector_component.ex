defmodule GuitarNotesWeb.Components.ChordSelectorComponent do
  use Phoenix.LiveComponent

  alias GuitarNotes.Model.Chord
  alias GuitarNotes.ChordBuilder, as: Builder

  def render(assigns) do
    assigns = assign_new(assigns, :chords, fn -> [default_chord()] end)

    ~H"""
    <div class="chords container">
      <%= for chord <- @chords do %>
        <div class="chord-selector row">
          <div class="col-1"><%= Chord.pretty(chord.tonic) %></div>
          <.build_selectors chord={chord}/>
        </div>
      <% end %>
    </div>
    """
  end

  defp default_chord() do
    {:ok, chord} = Builder.build(:e, third: :min, fifth: :perfect)
    chord
  end

  defp build_selectors(assigns) do
    chord = assigns.chord
    intervals = Builder.get_intervals(chord)

    assigns = assign(assigns, :intervals, intervals)

    ~H"""
    <%= for {type, interval} <- @intervals do %>
      <div class="col-2">
        <label><%= type %></label>
        <.interval_selector type={type} selected={interval}/>
      </div>
    <% end %>
    """
  end

  defp interval_selector(assigns) do
    selections = selections_from_type(assigns.type)
    assigns = assign(assigns, :selections, selections)

    ~H"""
    <select selected={@selected}>
      <%= for selection <- @selections do %>
        <option value={selection}><%= selection %></option>
      <% end %>
    </select>
    """
  end

  defp selections_from_type(:third), do: ["maj", "min"]
  defp selections_from_type(:fifth), do: ["diminished", "perfect", "augmented"]

  #   <label>Third</label>
  # <select class="col-6">
  #   <option value="maj">Maj</option>
  #   <option value="min">Min</option>
  # </select>
end
