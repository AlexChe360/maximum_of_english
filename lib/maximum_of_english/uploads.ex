defmodule MaximumOfEnglish.Uploads do
  @moduledoc """
  Handles file upload storage and deletion on the local filesystem.
  Files are stored in priv/static/uploads/{subdir}/{uuid}{ext}.
  """

  @doc """
  Consumes an upload from the socket and saves it to disk.
  Returns the URL path (e.g., "/uploads/videos/abc123.mp4") or nil if no file was uploaded.
  """
  def save_upload(socket, upload_name, subdir) do
    case Phoenix.LiveView.uploaded_entries(socket, upload_name) do
      {[_entry | _], _} ->
        [path] =
          Phoenix.LiveView.consume_uploaded_entries(socket, upload_name, fn %{path: tmp_path}, entry ->
            ext = Path.extname(entry.client_name)
            filename = generate_filename() <> ext
            dest_dir = static_path("uploads/#{subdir}")
            File.mkdir_p!(dest_dir)
            dest = Path.join(dest_dir, filename)
            File.cp!(tmp_path, dest)
            {:ok, "/uploads/#{subdir}/#{filename}"}
          end)

        path

      _ ->
        nil
    end
  end

  @doc """
  Deletes a file given its URL path. Only deletes files within the uploads directory.
  Safe to call with nil or non-upload paths.
  """
  def delete_file(nil), do: :ok
  def delete_file(""), do: :ok

  def delete_file("/uploads/" <> rest) do
    full_path = static_path("uploads/#{rest}")
    uploads_root = static_path("uploads") |> Path.expand()

    if String.starts_with?(Path.expand(full_path), uploads_root) do
      File.rm(full_path)
    end

    :ok
  end

  def delete_file(_), do: :ok

  def static_uploads_path(subdir) do
    static_path("uploads/#{subdir}")
  end

  def generate_unique_filename(ext) do
    generate_filename() <> ext
  end

  defp static_path(path) do
    Application.app_dir(:maximum_of_english, "priv/static/#{path}")
  end

  defp generate_filename do
    :crypto.strong_rand_bytes(16) |> Base.hex_encode32(case: :lower, padding: false)
  end
end
