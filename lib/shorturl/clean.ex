defmodule Shorturl.Clean do
  alias Shorturl.Links
  require Logger

  def delete_old_links do
    Logger.info("Running job for old links")
    {count, _} = Links.delete_all_old()
    Logger.info("Removed #{count} old links")
  end
end
