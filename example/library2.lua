return {
    getName = function ()
        return os.getenv("USER") or os.getenv("USERNAME") or "World"
    end
}