defmodule MaximumOfEnglishWeb.Admin.LessonLive.Form do
  use MaximumOfEnglishWeb, :live_view

  alias MaximumOfEnglish.{Courses, Uploads}
  alias MaximumOfEnglish.Courses.Lesson

  @impl true
  def mount(params, _session, socket) do
    week = Courses.get_week!(params["week_id"])

    {lesson, title} =
      case params do
        %{"id" => id} -> {Courses.get_lesson!(id), "Edit Lesson"}
        _ -> {%Lesson{week_id: week.id, kind: "grammar"}, "New Lesson"}
      end

    changeset = Courses.change_lesson(lesson)

    socket =
      socket
      |> assign(page_title: title)
      |> assign(week: week)
      |> assign(lesson: lesson)
      |> assign(form: to_form(changeset))
      |> assign(selected_kind: lesson.kind || "grammar")
      |> allow_upload(:video, accept: :any, max_entries: 1, max_file_size: 1_000_000_000)
      |> allow_upload(:audio, accept: :any, max_entries: 1, max_file_size: 50_000_000)
      |> allow_upload(:image, accept: ~w(.jpg .jpeg .png .gif .webp), max_entries: 1, max_file_size: 10_000_000)
      |> allow_upload(:file, accept: :any, max_entries: 1, max_file_size: 50_000_000)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>{@page_title} — Week {@week.number}</.header>

      <div class="card bg-base-200 shadow-sm max-w-2xl">
        <div class="card-body">
          <.form for={@form} phx-change="validate" phx-submit="save">
            <.input type="hidden" field={@form[:week_id]} />

            <.input
              field={@form[:kind]}
              type="select"
              label="Lesson Type"
              options={[{"Grammar", "grammar"}, {"Reading", "reading"}, {"Listening", "listening"}]}
            />

            <.input field={@form[:title]} label="Title" required />
            <.input field={@form[:position]} type="number" label="Position" required />

            <%!-- Dynamic fields based on kind --%>
            <div :if={@selected_kind == "grammar"} class="space-y-2">
              <div class="divider text-sm">Grammar Fields</div>
              <.upload_field upload={@uploads.video} label="Video" current={@lesson.video_url} remove_event="remove_video" />
              <.upload_field upload={@uploads.file} label="Materials File" current={@lesson.file_url} remove_event="remove_file" />
              <.wysiwyg field={@form[:description]} label="Description" id="quill-grammar" />
            </div>

            <div :if={@selected_kind == "reading"} class="space-y-2">
              <div class="divider text-sm">Reading Fields</div>
              <.wysiwyg field={@form[:description]} label="Text Content" id="quill-reading" />
              <.input field={@form[:vocabulary]} type="textarea" label="Vocabulary" rows="5" />
              <.upload_field upload={@uploads.image} label="Image" current={@lesson.image_url} remove_event="remove_image" />
            </div>

            <div :if={@selected_kind == "listening"} class="space-y-2">
              <div class="divider text-sm">Listening Fields</div>
              <.upload_field upload={@uploads.audio} label="Audio" current={@lesson.audio_url} remove_event="remove_audio" />
              <.wysiwyg field={@form[:description]} label="Description" id="quill-listening" />
              <.upload_field upload={@uploads.image} label="Image" current={@lesson.image_url} remove_event="remove_image" />
            </div>

            <div class="flex gap-2 mt-4">
              <button type="submit" class="btn btn-primary">Save</button>
              <.link navigate={~p"/admin/weeks/#{@week.id}/lessons"} class="btn btn-ghost">Cancel</.link>
            </div>
          </.form>
        </div>
      </div>
    </Layouts.app>

    <script :type={Phoenix.LiveView.ColocatedHook} name=".QuillEditor">
      export default {
        mounted() {
          const hiddenInput = this.el.querySelector("input[type=hidden]");
          const editorDiv = this.el.querySelector(".quill-container");
          const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");

          this.quill = new Quill(editorDiv, {
            theme: "snow",
            modules: {
              toolbar: {
                container: [
                  [{ header: [1, 2, 3, false] }],
                  ["bold", "italic", "underline"],
                  [{ list: "ordered" }, { list: "bullet" }],
                  ["link", "image", "clean"]
                ],
                handlers: {
                  image: function() {
                    const input = document.createElement("input");
                    input.setAttribute("type", "file");
                    input.setAttribute("accept", "image/*");
                    input.click();

                    input.onchange = async () => {
                      const file = input.files[0];
                      if (!file) return;

                      const formData = new FormData();
                      formData.append("file", file);

                      const res = await fetch("/admin/upload", {
                        method: "POST",
                        headers: { "x-csrf-token": csrfToken },
                        body: formData
                      });

                      const data = await res.json();
                      const range = this.quill.getSelection(true);
                      this.quill.insertEmbed(range.index, "image", data.url);
                      this.quill.setSelection(range.index + 1);
                    };
                  }
                }
              }
            }
          });

          // Load initial content
          if (hiddenInput.value) {
            this.quill.root.innerHTML = hiddenInput.value;
          }

          // Sync Quill content to hidden input on change
          this.quill.on("text-change", () => {
            const html = this.quill.root.innerHTML;
            hiddenInput.value = html === "<p><br></p>" ? "" : html;
            hiddenInput.dispatchEvent(new Event("input", { bubbles: true }));
          });
        }
      }
    </script>
    """
  end

  defp wysiwyg(assigns) do
    ~H"""
    <div class="mb-2">
      <label class="label text-sm font-semibold">{@label}</label>
      <div id={@id} phx-hook=".QuillEditor" phx-update="ignore">
        <input type="hidden" name={@field.name} value={@field.value || ""} />
        <div class="quill-container"></div>
      </div>
    </div>
    """
  end

  defp upload_field(assigns) do
    ~H"""
    <div class="mb-2">
      <label class="label text-sm font-semibold">{@label}</label>

      <%!-- Current file --%>
      <div :if={@current && @current != ""} class="flex items-center gap-2 mb-2 p-2 bg-base-100 rounded-lg">
        <.icon name="hero-paper-clip" class="size-4 text-base-content/60" />
        <span class="text-sm flex-1 truncate">{Path.basename(@current)}</span>
        <button type="button" phx-click={@remove_event} class="btn btn-ghost btn-xs text-error">
          <.icon name="hero-x-mark" class="size-4" /> Remove
        </button>
      </div>

      <%!-- Upload input --%>
      <.live_file_input upload={@upload} class="file-input file-input-bordered w-full" />

      <%!-- Entries (pending uploads) --%>
      <%= for entry <- @upload.entries do %>
        <div class="flex items-center gap-2 mt-2">
          <span class="text-sm flex-1 truncate">{entry.client_name}</span>
          <progress class="progress progress-primary w-24" value={entry.progress} max="100" />
          <span class="text-xs text-base-content/60">{entry.progress}%</span>
          <button type="button" phx-click="cancel_upload" phx-value-ref={entry.ref} phx-value-name={@upload.name} class="btn btn-ghost btn-xs text-error">
            <.icon name="hero-x-mark" class="size-4" />
          </button>
        </div>
        <%= for err <- upload_errors(@upload, entry) do %>
          <p class="text-error text-sm mt-1">{upload_error_to_string(err)}</p>
        <% end %>
      <% end %>

      <%!-- Upload-level errors --%>
      <%= for err <- upload_errors(@upload) do %>
        <p class="text-error text-sm mt-1">{upload_error_to_string(err)}</p>
      <% end %>
    </div>
    """
  end

  defp upload_error_to_string(:too_large), do: "File is too large"
  defp upload_error_to_string(:too_many_files), do: "Too many files"
  defp upload_error_to_string(:not_accepted), do: "File type not accepted"
  defp upload_error_to_string(err), do: "Error: #{inspect(err)}"

  @impl true
  def handle_event("validate", %{"lesson" => params}, socket) do
    changeset = Courses.change_lesson(socket.assigns.lesson, params)
    selected_kind = params["kind"] || socket.assigns.selected_kind

    socket =
      socket
      |> assign(form: to_form(changeset, action: :validate))
      |> assign(selected_kind: selected_kind)

    {:noreply, socket}
  end

  @impl true
  def handle_event("save", %{"lesson" => params}, socket) do
    lesson = socket.assigns.lesson

    # Consume uploads and build URL params
    params =
      params
      |> maybe_put_upload(socket, :video, "video_url", "videos", lesson)
      |> maybe_put_upload(socket, :audio, "audio_url", "audio", lesson)
      |> maybe_put_upload(socket, :image, "image_url", "images", lesson)
      |> maybe_put_upload(socket, :file, "file_url", "files", lesson)

    result =
      if lesson.id do
        Courses.update_lesson(lesson, params)
      else
        Courses.create_lesson(params)
      end

    case result do
      {:ok, _lesson} ->
        {:noreply,
         socket
         |> put_flash(:info, "Lesson saved successfully.")
         |> push_navigate(to: ~p"/admin/weeks/#{socket.assigns.week.id}/lessons")}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
    end
  end

  @impl true
  def handle_event("cancel_upload", %{"ref" => ref, "name" => name}, socket) do
    {:noreply, cancel_upload(socket, String.to_existing_atom(name), ref)}
  end

  @impl true
  def handle_event("remove_video", _params, socket) do
    Uploads.delete_file(socket.assigns.lesson.video_url)
    {:noreply, update_lesson_field(socket, :video_url, nil)}
  end

  @impl true
  def handle_event("remove_audio", _params, socket) do
    Uploads.delete_file(socket.assigns.lesson.audio_url)
    {:noreply, update_lesson_field(socket, :audio_url, nil)}
  end

  @impl true
  def handle_event("remove_image", _params, socket) do
    Uploads.delete_file(socket.assigns.lesson.image_url)
    {:noreply, update_lesson_field(socket, :image_url, nil)}
  end

  @impl true
  def handle_event("remove_file", _params, socket) do
    Uploads.delete_file(socket.assigns.lesson.file_url)
    {:noreply, update_lesson_field(socket, :file_url, nil)}
  end

  defp update_lesson_field(socket, field, value) do
    lesson = socket.assigns.lesson

    if lesson.id do
      {:ok, updated} = Courses.update_lesson(lesson, %{field => value})
      assign(socket, lesson: updated)
    else
      assign(socket, lesson: Map.put(lesson, field, value))
    end
  end

  defp maybe_put_upload(params, socket, upload_name, param_key, subdir, lesson) do
    case Uploads.save_upload(socket, upload_name, subdir) do
      nil ->
        params

      new_path ->
        # Delete old file if replacing
        old_path = Map.get(lesson, String.to_existing_atom(param_key))
        if old_path, do: Uploads.delete_file(old_path)
        Map.put(params, param_key, new_path)
    end
  end
end
