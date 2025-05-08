class << Erio
  def is_get(*arg, &blk);  on(verb('get'), *arg, &blk) ;end
  def is_post(*arg, &blk); on(verb('post'), *arg, &blk) ;end
  def is_delete(*arg, &blk); on(verb('delete'), *arg, &blk) ;end
end