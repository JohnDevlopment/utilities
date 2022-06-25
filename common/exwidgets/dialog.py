"""Common dialog windows.

Functions
    ask_string() -- ask for a string of user input
"""
from tkinter.simpledialog import Dialog
from tkinter import ttk, Tk, messagebox
from .entry import ExEntry
from .constants import *

class QueryDialog(Dialog):
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
        super().__init__(parent, title)

    def body(self, master):
        body = ttk.Frame(self)
        body.pack(fill='both')

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

    def buttonbox(self):
        box = ttk.Frame(self)

        w = ttk.Button(box, text='OK', width=10, command=self.ok, default=ACTIVE)
        w.pack(side=LEFT, padx=5, pady=5)
        w = ttk.Button(box, text="Cancel", width=10, command=self.cancel)
        w.pack(side=LEFT, padx=5, pady=5)

        self.bind("<Return>", self.ok)
        self.bind("<Escape>", self.cancel)

        box.pack()

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
        super().__init__(title=title, prompt=prompt, **kw)

    def get_result(self):
        return self.getdouble(self.entry.subcmd('get'))

class _QueryInteger(QueryDialog):
    errormessage = "Not an integer."

    def __init__(self, title: str, prompt: str, **kw):
        super().__init__(title=title, prompt=prompt, **kw)

    def get_result(self):
        return self.getint(self.entry.subcmd('get'))

class _QueryString(QueryDialog):
    def __init__(self, title: str, prompt: str, **kw):
        super().__init__(title=title, prompt=prompt, **kw)

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
    from ._test import test_dialog
    root = Tk()
    root.title('Dialog Test')
    root.geometry('100x100')
    ttk.Button(root, text='Get String', width=10, command=lambda: test_dialog(root, 'getstring')).pack()
    ttk.Button(root, text='Get Integer', width=10, command=lambda: test_dialog(root, 'getint')).pack()
    ttk.Button(root, text='Get Float', width=10, command=lambda: test_dialog(root, 'getfloat')).pack()
    root.mainloop()
