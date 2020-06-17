from pythonfuzz.main import PythonFuzz

from black import lib2to3_parse, get_future_imports, LineGenerator, EmptyLineTracker


@PythonFuzz
def fuzz(buf):
    try:
        src_node = lib2to3_parse(buf.lstrip().decode('utf-8'))
    except Exception:
        # not interested in bad input here
        return

    future_imports = get_future_imports(src_node)

    normalize_strings = True
    lines = LineGenerator(
        remove_u_prefix="unicode_literals" in future_imports,
        normalize_strings=normalize_strings,
    )
    elt = EmptyLineTracker()

    for current_line in lines.visit(src_node):
        before, after = elt.maybe_empty_lines(current_line)


if __name__ == '__main__':
    fuzz()

