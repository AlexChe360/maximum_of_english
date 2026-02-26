defmodule MaximumOfEnglish.Uploads do
  @moduledoc """
  Handles file upload storage and deletion on the local filesystem.
  Files are stored in {upload_dir}/{subdir}/{uuid}{ext}.

  In dev, defaults to priv/static/uploads.
  In prod, uses UPLOAD_PATH env var (e.g., /var/data/uploads).
  """

  @doc """
  Returns the root uploads directory.
  """
  def upload_dir do
    Application.get_env(:maximum_of_english, :upload_path) ||
      Application.app_dir(:maximum_of_english, "priv/static/uploads")
  end

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
            dest_dir = Path.join(upload_dir(), subdir)
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
    full_path = Path.join(upload_dir(), rest)
    uploads_root = upload_dir() |> Path.expand()

    if String.starts_with?(Path.expand(full_path), uploads_root) do
      File.rm(full_path)
    end

    :ok
  end

  def delete_file(_), do: :ok

  def static_uploads_path(subdir) do
    Path.join(upload_dir(), subdir)
  end

  def generate_unique_filename(ext) do
    generate_filename() <> ext
  end

  defp generate_filename do
    :crypto.strong_rand_bytes(16) |> Base.hex_encode32(case: :lower, padding: false)
  end
end
