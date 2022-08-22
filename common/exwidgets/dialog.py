"""Common dialog windows.

Functions
    ask_string()  -- ask for a string of user input
    ask_float()   -- query the user for a floating point value
    ask_integer() -- query the user for an integer number
"""
from tkinter import ttk, Tk, messagebox, Toplevel, _get_temp_root
from tkinter.simpledialog import (_setup_dialog, _place_window, _destroy_temp_root,
_get_temp_root, _destroy_temp_root)
from .entry import ExEntry
from .constants import *

class ExDialog(Toplevel):
    """Class to open dialogs.

    This class is intended as a base class for custom dialogs.
    """
    def __init__(self, parent, title=None):
        """Initialize a dialog.

        Arguments:
            parent -- a parent window (the application window)

            title -- the dialog title

        Attributes:
            result -- result of the dialog

            frame -- a tkinter.ttk.Frame that holds all of the dialog's children
        """
        master = parent
        if master is None:
            master = _get_temp_root()

        Toplevel.__init__(self, master)

        # Remain invisible for now
        self.withdraw()

        # If the parent is not viewable, don't
        # make the child transient, or else it
        # would be opened withdrawn
        if parent is not None and parent.winfo_viewable():
            self.transient(parent)

        if title:
            self.title(title)

        _setup_dialog(self)

        self.parent = master
        self.result = None

        body = ttk.Frame(self)
        body.pack(fill=BOTH, ipadx=5, ipady=5, expand=True)
        self.frame = body
        self.initial_focus = self.body(body)

        self.buttonbox()

        if self.initial_focus is None:
            self.initial_focus = self

        self.protocol("WM_DELETE_WINDOW", self.cancel)

        _place_window(self, parent)

        self.initial_focus.focus_set()

        # Wait for window to appear on screen before calling grab_set
        self.wait_visibility()
        self.grab_set()
        self.wait_window(self)

    def destroy(self):
        """Destroy the window."""
        self.initial_focus = None
        Toplevel.destroy(self)
        _destroy_temp_root(self.master)

    #
    # construction hooks

    def body(self, master):
        """Create dialog body.

        Return widget that should have initial focus.
        This method should be overridden, and is called
        by the __init__() method.

        MASTER is a ttk.Frame packed directly under the Toplevel.
        """
        pass

    def buttonbox(self):
        """Add standard button box.

        Override if you do not want the standard buttons.
        """
        box = ttk.Frame(self.frame)
        box.pack(fill=BOTH, expand=True)

        w = ttk.Button(box, text='OK', width=10, command=self.ok, default=ACTIVE)
        w.pack(side=LEFT, padx=5, pady=5)

        w = ttk.Button(box, text="Cancel", width=10, command=self.cancel)
        w.pack(side=LEFT, padx=5, pady=5)

        self.bind("<Return>", self.ok)
        self.bind("<Escape>", self.cancel)

    #
    # standard button semantics

    def ok(self, event=None):
        if not self.validate():
            self.initial_focus.focus_set() # put focus back
            return

        self.withdraw()
        self.update_idletasks()

        try:
            self.apply()
        finally:
            self.cancel()

    def cancel(self, event=None):
        # put focus back to the parent window
        if self.parent is not None:
            self.parent.focus_set()
        self.destroy()

    #
    # command hooks

    def validate(self):
        """Validate the data.

        This method is called automatically to validate the data before the
        dialog is destroyed. By default, it always validates OK.

        Override this method to implement custom validation.
        """
        return True

    def apply(self):
        """Process the data.

        This method is called automatically to process the data, *after*
        the dialog is destroyed. By default, it does nothing.

        Override this method to implement custom behavior.
        """
        pass

class ExConfirmation(ExDialog):
    """Confirmation dialog.

    Use `self.result` to get the result of the dialog, True
    for ok or False for cancel.
    """
    def __init__(self, parent, text=None, *args, **kw):
        """Initializes a confirmation dialog with the given parent PARENT.

        TEXT is the dialog text to display.
        """
        self.text = text or ''
        super().__init__(parent, *args, **kw)

    def buttonbox(self):
        box = ttk.Frame(self.frame)
        box.pack(fill=BOTH)

        w = ttk.Button(box, text='OK', width=10, command=self.ok, default=ACTIVE)
        w.pack(side=TOP, padx=5, pady=5)

        self.bind("<Return>", self.ok)

    def body(self, master):
        body = ttk.Frame(master)
        body.pack(fill=BOTH)

        label = ttk.Label(body, text=self.text or '', justify=CENTER, anchor=N)
        label.pack(fill=BOTH, side=TOP, anchor=N)

        return label

class QueryDialog(ExDialog):
    def __init__(self, parent=None, title=None, prompt=None, text=None,
                 initialval=None, minvalue=None, maxvalue=None):
        """Initialize a dialog for querying user input.

        Arguments:
            parent -- a parent window (the application window)

            title -- the dialog title

            prompt -- the prompt

            text -- label text (goes before the prompt)

            initialval = the initial value of the entry

            minvalue = the minimum value

            maxvalue = the maximum value
        """
        self.prompt = prompt
        self.text = text
        self.result = None
        self.initialval = initialval
        self.minvalue = minvalue
        self.maxvalue = maxvalue
        ExDialog.__init__(self, parent, title)

    def body(self, master):
        body = ttk.Frame(master)
        body.pack(fill=BOTH, expand=True)

        if self.text is not None:
            label = ttk.Label(body, text=self.text, justify=LEFT)
            label.pack(padx=5)

        if self.prompt is not None:
            label = ttk.Label(body, text=self.prompt, justify=LEFT)
            label.pack(padx=5)

        self.entry = ExEntry(body)
        if self.initialval is not None:
            self.entry.subcmd('insert', 0, self.initialval)
            self.entry.select_range(0, END)
        self.entry.pack(padx=5, fill=X)

        return self.entry

    def validate(self):
        try:
            result = self.get_result()
        except ValueError:
            messagebox.showwarning(
                "Illegal Value",
                self.errormessage + "\nPlease try again",
                parent = self
            )
            return False

        if self.minvalue is not None and result < self.minvalue:
            messagebox.showwarning(
                "Too small",
                "The allowed minimum value is %s. "
                "Please try again." % self.minvalue,
                parent = self
            )
            return False

        if self.maxvalue is not None and result > self.maxvalue:
            messagebox.showwarning(
                "Too large",
                "The allowed maximum value is %s. "
                "Please try again." % self.maxvalue,
                parent = self
            )
            return False

        self.result = result

        return True

class _QueryFloat(QueryDialog):
    errormessage = "Not an integer."

    def __init__(self, title: str, prompt: str, **kw):
        QueryDialog.__init__(self, title=title, prompt=prompt, **kw)

    def get_result(self):
        return self.getdouble(self.entry.subcmd('get'))

class _QueryInteger(QueryDialog):
    errormessage = "Not an integer."

    def __init__(self, title: str, prompt: str, **kw):
        QueryDialog.__init__(self, title=title, prompt=prompt, **kw)

    def get_result(self):
        return self.getint(self.entry.subcmd('get'))

class _QueryString(QueryDialog):
    def __init__(self, title: str, prompt: str, **kw):
        QueryDialog.__init__(self, title=title, prompt=prompt, **kw)

    def get_result(self):
        return self.entry.subcmd('get')

def ask_float(title: str, prompt: str, **kw):
    """Get a string from the user.

    Arguments:
        title = the dialog title

        prompt -- the label text

        **kw = see QueryDialog class
    """
    d = _QueryFloat(title, prompt, **kw)
    return d.result

def ask_integer(title: str, prompt: str, **kw):
    """Get a string from the user.

    Arguments:
        title = the dialog title

        prompt -- the label text

        **kw = see QueryDialog class
    """
    d = _QueryInteger(title, prompt, **kw)
    return d.result

def ask_string(title: str, prompt: str, **kw):
    """Get a string from the user.

    Arguments:
        title = the dialog title

        prompt -- the label text

        **kw = see QueryDialog class
    """
    d = _QueryString(title, prompt, **kw)
    return d.result

if __name__ == '__main__':
    import sys
    from ._test import _detect_help, test_dialog
    from tkinter import Tk

    print("Testing dialogs...")
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

    test_dialog(Tk(), opts)
