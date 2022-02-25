defmodule GuitarNotesWeb.Components.ChordSelectorComponent do
  use Phoenix.LiveComponent
  use Phoenix.HTML

  alias GuitarNotes.Model.Chord
  alias GuitarNotes.ChordBuilder, as: Builder

  def render(assigns) do
    changesets = Map.new(assigns.chords, fn {tonic, chord} -> {tonic, changeset(chord)} end)
    assigns = assign(assigns, :changesets, changesets)

    ~H"""
    <div class="chords container">
      <%= for {_, chord} <- @chords do %>
        <div class="chord-selector row">
          <.form let={f} for={@changesets[chord.tonic]} phx-change="chord_change">
            <%= label f, :tonic %>
            <%= text_input f, chord.tonic, value: Chord.pretty(chord.tonic) %>
            <.build_selectors chord={chord} form={f}}/>
          </.form>
        </div>
      <% end %>
      <div phx-click="add_chord">Add chord</div>
    </div>
    """
  end

  defp changeset(chord), do: Ecto.Changeset.change(chord, %{})

  defp build_selectors(assigns) do
    intervals = Builder.get_intervals(assigns.chord)
    assigns = assign(assigns, :intervals, intervals)

    ~H"""
    <%= for {type, interval} <- @intervals do %>
      <div class="col-2">
        <%= label @form, type %>
        <.interval_selector type={type} selected={interval} form={@form} chord={@chord}/>
      </div>
    <% end %>
    """
  end

  defp interval_selector(assigns) do
    selections = selections_from_type(assigns.type)
    assigns = assign(assigns, :selections, selections)

    ~H"""
    <%= select @form, @type, @selections, selected: @selected %>
    """
  end

  defp selections_from_type(:third), do: ["maj", "min"]
  # TODO: should add augmented in the future
  defp selections_from_type(:fifth), do: ["diminished", "perfect"]

  # <select selected={@selected}>
  #   <%= for selection <- @selections do %>
  #     <option value={selection}><%= selection %></option>
  #   <% end %>
  # </select>

  #   <label>Third</label>
  # <select class="col-6">
  #   <option value="maj">Maj</option>
  #   <option value="min">Min</option>
  # </select>
end
