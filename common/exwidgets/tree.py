from exwidgets import ExWidget, _val_or_dict
from tkinter import ttk, _stringify
from tkinter.ttk import _format_optdict
from enum import Enum

class Pattern(Enum):
    """Search pattern type."""
    GLOB = 'glob'
    REGEX = 'regex'
    EXACT = 'exact'

class ExTree(ExWidget):
    """Extended treeview widget.

    ITEM OPTIONS
        text: string
            Textual label to display for this item.
        image: image_name
            A Tk image to display to the left of the label.
        values: list
            The list of values associated with this item.

            Ideally the list should have the same number of elements as there are columns.
            If the list has fewer elements than the column count, the extra coumns will be empty.
            If it has more elements than the column count, the extra elements are ignored.
        open: bool
            If true the item's children are displayed.
        tags: list
            A list of tags to be applied.
    """

    def __init__(self, master, cnf={}, **kwargs):
        """Construct and initialize a ExTree object.

        ExTree options:
        scrollx <bool>  -- if true, a horizontal scrollbar is added
        scrolly <bool>  -- if true, a vertical scrollbar is added
        headings <list> -- a list of column-heading pairs that set the column IDs and their headings

        Any other option is presumed to be a ttk treeview widget option.

        STANDARD OPTIONS

            class, cursor, style, takefocus, xscrollcommand,
            yscrollcommand

        WIDGET-SPECIFIC OPTIONS

            columns, displaycolumns, height, padding, selectmode, show

        ITEM OPTIONS

            text, image, values, open, tags

        TAG OPTIONS

            foreground, background, font, image
        """
        ExWidget.__init__(self, master, cnf, kwargs)
        cnf = self.cnf

        # Process options
        entryOpts = {}
        exOpts = {}
        for k, v in cnf.items():
            match k:
                case 'scrollx' | 'scrolly':
                    if v:
                        exOpts[k] = True
                case 'headings':
                    exOpts['headings'] = v
                case _:
                    entryOpts[k] = v

        frame = ttk.Frame(self._master)

        self._tk.call(('exw', 'tree') + self._options(exOpts) + (str(frame),) + self._options(entryOpts))
        self._widget = frame

    def clear(self):
        """Clears the entire tree of its data."""
        self._tk.call('exw', 'subcmd', self._widget, 'clear')

    def column(self, column, option=None, **kwargs):
        """Query or modify options for the specified column.

        If KWARGS is not given, returns a dict of the column option values. If
        OPTION is specified then the value for that option is returned.
        Otherwise, sets the options to the corresponding values.

        Valid options/values are:
            id
                This is a readonly option. Returns the id of the column.
            anchor: anchor
                Specifies how the text in the column should be aligned with respect to their cell.
                Valid options: n, ne, e, se, s, sw, w, nw, or center.
            minwidth: int
                The minimum width of the column in pixels (default is 20). The treeview widget
                will not make the column any smaller than this option when the widget is resized
                or the user drags a column separator.
            stretch: bool
                Specifies whether or not the column width should be adjusted when the widget is
                resized or the user drags a column separator. Be default this option is true.
            width: int
                The width of the column in pixels (default is 200). The specified column width
                may be changed by Tk in order to honor stretch and/or minwidth, or when the
                user drags a column separator, or when the widget is resized.
        """
        if option is not None:
            kwargs[option] = None
        return _val_or_dict(self._tk, kwargs, 'exw', 'subcmd', str(self._widget), 'column', column)

    def heading(self, column, option=None, **kwargs):
        """Query or modify heading options for the specified column.

        If KWARGS is not given, returns a dict of the heading option values. If
        OPTION is specified then the value for that option is returned.
        Otherwise, sets the options to the corresponding values.

        Valid options/values are:
            text: string
                The text to display in the column heading.
            image: image_name
                Name of the image to display to the right of the heading text.
            anchor: anchor
                Specifies how the heading text should be aligned.
                Valid options: n, ne, e, se, s, sw, w, nw, or center.
            command: callback
                Command to be run when the heading label is pressed.
        """
        if option is not None:
            kwargs[option] = None
        return _val_or_dict(self._tk, kwargs, 'exw', 'subcmd', str(self._widget), 'heading', column)

    def insert(self, parent, index, /, iid=None, **kwargs):
        """Creates a new item and returns its identifier.

        PARENT is the item id of the parent, or an empty string to create
        a new toplevel item.
        INDEX is an integer or the value end, specifying where
        to place the new item. If INDEX is less than or equal to zero, the item is placed
        at the beginning; if greater than or equal to the number of children,
        it's put at the end instead.
        IID, if provided, specifies the id of the newly created item. IID cannot be already
        assigned to an item. If this option is not provided, a unique identifier is generated.

        KWARGS specifies options to customize the new item. Valid options are described under
        "ITEM OPTIONS".
        """
        opts = _format_optdict(kwargs)
        if iid is not None:
            res = self._tk.call('exw', 'subcmd', self._widget, 'insert', parent, index,
                                '-id', iid, *opts)
        else:
            res = self._tk.call('exw', 'subcmd', self._widget, 'insert', parent, index, *opts)
        return res

    #defs

    def itemindex(self, index):
        """Finds and returns the item located at the specified index."""
        self._tk.call('exw', 'subcmd', self._widget, 'itemindex', index)

    def search(self, column, pattern: str, /, type=Pattern.GLOB):
        """Searches the entire tree for an item whose column matches the pattern.

        Upon the first match of PATTERN, the item id is returned; if there is no such match,
        an empty string is returned. COLUMN must be a valid column identifier.
        TYPE specifies what kind of matching algorithm gets used and how PATTERN is treated:
            Pattern.GLOB
                A glob-style pattern in the vein of string match
            Pattern.REGEX
                A regular expression pattern
            Pattern.EXACT
                An exact match using the string equality operator
        """
        opts = [column, pattern]
        if type is not Pattern.GLOB:
            opts.insert(1, '-' + type)
        self._tk.call('exw', 'subcmd', self._widget, 'search', *opts)
