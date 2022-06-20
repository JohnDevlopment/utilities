from exwidgets import ExWidget
import tkinter as tk

class ExText(ExWidget):
    """Extended text widget.

    ExText builds on top of the text widget, adding some features such as
    automatic scrollbars.
    """

    def __init__(self, master, cnf={}, **kwargs):
        """Construct and initialize a text widget under its master.

        ExText options:
        wrap (word|char|none)    -- Specifies the way the widget will handle lines in the text that
                                    are too long to display on one screen line.
                                    If the option is none, the text line will be displayed on exactly one
                                    line on the screen; extra characters that do not fit on the screen
                                    are simply not displayed. In the other modes the text line is
                                    split across two or more screen lines.
                                    In char mode the line break may occur after any character;
                                    in word the line break is made only after a word boundary.
        scrolly <bool>           -- If true, a vertical scrollbar is displayed on the right side of the widget.
        disabledbackground <str> -- Specifies the background color to use when the widget is disabled.
                                    If this option is omitted or is an empty string, it defaults to the
                                    background color ttk::entry uses when it is disabled.

        STANDARD OPTIONS
 
            background, borderwidth, cursor,
            exportselection, font, foreground,
            highlightbackground, highlightcolor,
            highlightthickness, insertbackground,
            insertborderwidth, insertofftime,
            insertontime, insertwidth, padx, pady,
            relief, selectbackground,
            selectborderwidth, selectforeground,
            setgrid, takefocus,
            xscrollcommand, yscrollcommand
 
        WIDGET-SPECIFIC OPTIONS
 
            autoseparators, height, maxundo,
            spacing1, spacing2, spacing3,
            state, tabs, undo, width, wrap

        TAG OPTIONS

            background, bgstipple, borderwidth, elide, fgstipple, font, foreground, justify,
            lmargin1, lmargin2, lmargincolor, offset, overstrike, overstrikefg, relief, rmargin,
            rmargincolor, selectbackground, selectforeground, spacing1, spacing2, spacing3,
            tabs, tabstyle, underline, underlinefg, wrap
        """
        ExWidget.__init__(self, master, cnf, kwargs)
        cnf = self.cnf
        
        # Process options
        exOpts = []
        textOpts = []

        for k, v in cnf.items():
            if k in ('wrap', 'disabledbackground', 'scrolly'):
                if k == 'scrolly':
                    if v:
                        exOpts.append('-' + k)
                else:
                    exOpts.append('-' + k)
                    exOpts.append(str(v))
            else:
                textOpts.append('-' + k)
                textOpts.append(str(v))

        frame = tk.ttk.Frame(self._master)

        self._tk.call('exw', 'text', *exOpts, frame, *textOpts)
        self._widget = frame

    def tag_add(self, tagName, index1, *args):
        """Associate a tag TAGNAME with all the characters in a range.

        The range of characters between INDEX1 and index2 in ARGS are
        associated with the tag. There can be any number of index1-index2
        pairs. If the last index2 is omitted, then a single character at
        index1 is associated with the tag.
        """
        self._tk.call(
            ('exw', 'subcmd', self._widget, 'tag', 'add', tagName, index1) + args)

    def tag_bind(self, tagName, sequence, func, add=None):
        """"""
        return self._widget._bind(('exw', 'subcmd', self._widget, 'tag', 'bind', tagName),
                                  sequence, func, add)

    def tag_cget(self, tagName, option):
        """
        """
        if option[:1] != '-':
            option = '-' + option
        if option[-1:] == '_':
            option = option[:-1]
        return self._tk.call(
            'exw', 'subcmd', 'tag', 'cget', tagName, option)

    def tag_configure(self, tagName, cnf=None, **kwargs):
        """Modify options associated with a TAGNAME.

        If no options are specified, a list of all available options for TAGNAME is returned.
        If option-value pairs are provided, the tag TAGNAME is modified with the options
        specified.
        """
        return self._configure(('tag', 'configure', tagName), cnf, kwargs)

    def tag_delete(self, *tagNames):
        """Delete all tags in TAGNAMES."""
        self._tk.call(('exw', 'subcmd', self._widget, 'tag', 'delete') + tagNames)

    def tag_lower(self, tagName, belowThis=None):
        """Lower the priority of the tag TAGNAME.

        The priority of the tag will be just lower than BELOWTHIS if provided,
        otherwise it has the lowest priority in the stack.
        """
        self._tk.call('exw', 'subcmd', self._widget, 'tag', 'lower', tagName, belowThis)

    def tag_names(self, index=None):
        """Return a list of all tag names.

        If INDEX is provided, it specifies the INDEX for which the tags are associated.
        If INDEX is omitted, the tags for the entire text are returned.
        """
        return self._tk.splitlist(
            self._tk.call('exw', 'subcmd', self._widget, 'tag', 'names', index))

    def tag_nextrange(self, tagName, index1, index2=None):
        """Searches the text for a range of characters associated with a tag.

        Returns a list with the start and end index for the first sequence
        of characters between INDEX1 and INDEX2 that have the tag TAGNAME.
        The text is searched forwards from INDEX1. If INDEX2 is omitted, it
        defaults to the end of the text.
        """
        return self._tk.splitlist(self._tk.call(
            'exw', 'subcmd', self._widget, 'tag', 'nextrange', tagName, index1, index2))

    def tag_prevrange(self, tagName, index1, index2=None):
        """Searches the text for a range of characters associated with a tag.

        Returns a list with the start and end index for the first sequence
        of characters between INDEX1 and INDEX2 that have the tag TAGNAME.
        The text is searched backwards from INDEX1. If INDEX2 is omitted, it
        defaults to the beginning of the text.
        """
        return self._tk.splitlist(self._tk.call(
            self._widget, 'tag', 'prevrange', tagName, index1, index2))

    def tag_raise(self, tagName, aboveThis=None):
        """Raise the priority of the tag TAGNAME.

        The priority of the tag will be just higher than ABOVETHIS if provided,
        otherwise it has the highest priority in the stack.
        """
        self._tk.call('exw', 'subcmd', self._widget, 'tag', 'raise', tagName, aboveThis)

    def tag_ranges(self, tagName):
        """Return a list of ranges of text which have tag TAGNAME."""
        return self._tk.splitlist(self._tk.call('exw', 'subcmd', self._widget, 'tag', 'ranges', tagName))

    def tag_remove(self, tagName, index1, index2=None):
        """Remove tag TAGNAME from all characters between INDEX1 and INDEX2."""
        self._tk.call('exw', 'subcmd', self._widget, 'tag', 'remove', tagName, index1, index2)

if __name__ == "__main__":
    import sys
    from ._test import _detect_help, test_text

    print("Testing ExText...")
    args = sys.argv[1:]
    opts = {}

    if _detect_help(args, 'ExText'):
        sys.exit()

    if (len(args) % 1):
        raise ValueError("Must be even number of arguments")

    for i in range(len(args)):
        arg = args[i]
        
    test_text(tk.Tk(), opts)
