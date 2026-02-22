defmodule MaximumOfEnglishWeb.UploadController do
  use MaximumOfEnglishWeb, :controller

  alias MaximumOfEnglish.Uploads

  def create(conn, %{"file" => upload}) do
    ext = Path.extname(upload.filename)
    filename = Uploads.generate_unique_filename(ext)
    dest_dir = Uploads.static_uploads_path("editor")
    File.mkdir_p!(dest_dir)
    dest = Path.join(dest_dir, filename)
    File.cp!(upload.path, dest)

    json(conn, %{url: "/uploads/editor/#{filename}"})
  end
end
