from exwidgets import ExWidget
from tkinter import ttk

class ExEntry(ExWidget):
    """Extended entry widget.

    ExEntry builds on top of the ttk::entry widget, adding some extra features such as a
    clear button and a label.
    """

    def __init__(self, master, cnf={}, **kwargs):
        """Construct the widget under its master.

        ExEntry options:
        allowedchars <str> -- what kind of characters are allowed as a regular expression
        clearbutton <bool> -- if true, a clear button is added
        label <str>        -- textual string to display above the entry
        maxlen <int>       -- maximum number of characters allowed in the entry
        scrollx <bool>     -- if true, a horizontal scrollbar is added

        Any other option is presumed to be a ttk entry widget option.

        STANDARD OPTIONS

            class, cursor, style, takefocus, xscrollcommand

        WIDGET-SPECIFIC OPTIONS

            exportselection, invalidcommand, justify, show, state,
            textvariable, validate, validatecommand, width

        VALIDATION MODES

            none, key, focus, focusin, focusout, all
        """
        ExWidget.__init__(self, master, cnf, kwargs)
        cnf = self.cnf

        # Process options
        exOpts = list()
        entryOpts = list()

        for k, v in cnf.items():
            match k:
                case 'clearbutton' | 'scrollx':
                    if v:
                        exOpts.append('-' + k)
                case 'allowedchars' | 'label' | 'maxlen':
                    exOpts.append('-' + k)
                    exOpts.append(str(v))
                case _:
                    entryOpts.append('-' + k)
                    entryOpts.append(str(v))

        frame = ttk.Frame(self._master)

        self._tk.call('exw', 'entry', *exOpts, str(frame), *entryOpts)
        self._widget = frame

    def selection_adjust(self, index):
        """Adjust the end of the selection near the cursor to INDEX."""
        return self.subcmd('selection', 'adjust', index)

    select_adjust = selection_adjust

    def selection_clear(self):
        """Clear the selection if it is in this widget."""
        return self.subcmd('selection', 'clear')

    select_clear = selection_clear

    def selection_from(self, index):
        """Set the fixed end of a selection to INDEX."""
        return self.subcmd('selection', 'from', index)

    select_from = selection_from

    def selection_present(self):
        """Return True if there are characters selected in the entry, False
        otherwise."""
        return self._tk.getboolean(
            self.subcmd('selection', 'present'))

    select_present = selection_present

    def selection_range(self, start, end):
        """Set the selection from START to END (not included)."""
        return self.subcmd('selection', 'range', start, end)

    select_range = selection_range

if __name__ == "__main__":
    import sys
    from ._test import _detect_help, test_entry
    from tkinter import Tk

    print("Testing ExEntry...")
    args = sys.argv[1:]
    opts = {}

    # Detect -h|-?|--help
    if _detect_help(args, 'ExEntry'):
        sys.exit()

    if (len(args) % 1):
        raise ValueError("Must be even number of arguments")

    i = 0
    while i < len(args):
        (opt, arg) = args[i:i+2]
        opts[opt] = arg
        i += 2
        
    test_entry(Tk(), opts)
