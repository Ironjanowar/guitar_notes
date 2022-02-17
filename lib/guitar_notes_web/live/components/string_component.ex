defmodule GuitarNotesWeb.Components.StringComponent do
  use Phoenix.LiveComponent

  alias GuitarNotes.ChordBuilder

  def render(assigns) do
    start_note = assigns.note

    frets =
      start_note
      |> ChordBuilder.get_notes_from(12)
      |> Enum.with_index()
      |> Enum.map(fn {note, index} -> %{note: note, type: type_from_index(index)} end)

    assigns = assign(assigns, :frets, frets)

    ~H"""
    <div class="string">
      <%= for fret <- @frets do %>
        <div class={fret.type} data-note={fret.note}></div>
      <% end %>
    </div>
    """
  end

  # @single_mark [3, 5, 7, 9]
  # @double_mark [12]
  defp type_from_index(_index) do
    cond do
      # index in @single_mark -> "note-fret sigle-fretmark"
      # index in @double_mark -> "note-fret double-fretmark"
      true -> "note-fret"
    end
  end
end
