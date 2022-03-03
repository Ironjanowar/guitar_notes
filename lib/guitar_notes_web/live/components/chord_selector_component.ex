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
      <%= for tonic <- @chords_order do %>
        <div class="chord-selector row">
          <.form let={f} for={@changesets[tonic]} phx-change="chord_change" phx-submit="nothing" class="form-control">
            <button class="btn btn-danger bin-button" phx-click="remove_chord" phx-value-tonic={tonic}><i class="fa fa-trash-o"></i></button>
            <div class="col-xs-2">
              <%= label f, :tonic %>
              <%= text_input f, tonic, value: Chord.pretty(tonic), phx: [debounce: "blur"], class: "form-control" %>
            </div>
            <div class="col-xs-8">
              <.build_selectors chord={@chords[tonic]} form={f}}/>
            </div>
          </.form>
        </div>
      <% end %>
      <div class="row">
        <%= if @add_chord_enabled? do %>
          <button class="btn btn-primary" phx-click="add_chord">Add chord</button>
        <% end %>
      </div>
    </div>
    """
  end

  defp changeset(chord), do: Ecto.Changeset.change(chord, %{})

  defp build_selectors(assigns) do
    intervals = Builder.get_intervals(assigns.chord)
    assigns = assign(assigns, :intervals, intervals)

    ~H"""
    <%= for {type, interval} <- @intervals do %>
      <div class="col-xs-2">
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
    <%= select @form, @type, @selections, selected: @selected, class: "custom-select" %>
    """
  end

  defp selections_from_type(:third), do: [Maj: "maj", Min: "min"]

  defp selections_from_type(:fifth),
    do: [Diminished: "diminished", Perfect: "perfect", Augmented: "augmented"]

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
