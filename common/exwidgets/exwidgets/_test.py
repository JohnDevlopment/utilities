"""Internal module for testing other parts of exwidgets.

Contains helper functions.
"""
import re
from .text import ExText
from .entry import ExEntry
from .dialog import ask_string, ask_integer, ask_float, ExConfirmation, ExYesno
from tkinter import ttk, StringVar

_help_re = re.compile('-[h?]|--help')

def _detect_help(args: list, cls: str) -> bool:
    """Internal function."""
    global _help_re
    if _help_re.search(','.join(args)) is not None:
        print("### Help ###")
        print(f"Any arguments are treated as options for {cls}.",
              "Check the relevent doc for details.")
        return True

    return False

def test_dialog(root, opts):
    def _action(action: str):
        root.update()
        match action:
            case 'getstring':
                name = ask_string(
                    'Name',
                    'What Is Your Name?'
                )
                if name is None or name == '':
                    print('Okay, no-name')
                    return
                print("Your name is", name)
            case 'getfloat':
                balance = ask_float(
                    'Balance',
                    'Current Balance'
                )
                if balance is None:
                    print("No balance provided")
                    return
                print("Current balance:", balance)
            case 'getint':
                pin = ask_integer(
                    'Nosy',
                    'Your Secret PIN',
                    text="Forgive me for being nosy, but what is your secret PIN number?",
                    minvalue=1234,
                    maxvalue=9999
                )
                if pin is None:
                    print('Well! Sorry for asking!')
                    return
                print("I see. So your PIN number is '%s'. Thanks!" % pin)
            case 'confirm':
                d = ExYesno(root, 'Do you want rule the world?', title='Confirmation')
                print(d.result)
                if not d.result:
                    print("Awww, spoil sport!")
                    return
                name = ask_string(
                    'Your Name',
                    'Name Of Our New Ruler'
                )
                if name == '':
                    print("You didn't provide a name!")
                    return
                print(f"Hail our new overlord, {name}!")

    root.title('Dialog Test')
    #root.geometry('100x133')
    ttk.Button(root, text='Get String', width=10, command=lambda: _action('getstring')).pack()
    ttk.Button(root, text='Get Integer', width=10, command=lambda: _action('getint')).pack()
    ttk.Button(root, text='Get Float', width=10, command=lambda: _action('getfloat')).pack()
    ttk.Button(root, text='Confirmation Dialog', width=30, command=lambda: _action('confirm')).pack()
    root.mainloop()

    

def test_entry(root, opts):
    entry = ExEntry(root, opts)
    entry.pack()

    b = ttk.Button(root, text='Focus entry', command=lambda: entry.focus())
    b.pack()

    var = StringVar()
    label = ttk.Label(root, textvariable=var)
    label.pack()

    def _label(text):
        text = str(text)
        var.set(text)

    b = ttk.Button(root, text='Current focus',
                   command=lambda: _label(root.focus_displayof()))
    b.pack()

    b = ttk.Button(root, text='Entry Selection Bool',
                   command=lambda: _label(entry.select_present()))
    b.pack()
    
    root.mainloop()

def test_text(root, opts):
    text = ExText(root, opts)

    _print = lambda t, s: t.subcmd('insert', 'end', s)

    text.tag_configure('ERROR', foreground='red')
    text.tag_configure('WARNING', foreground='yellow')
    text.tag_configure('DEBUG', foreground='green')
    text.tag_configure('CLICKME')
    text.tag_raise('WARNING', 'ERROR')
    text.tag_raise('DEBUG')
    text.tag_lower('WARNING', 'ERROR')
    text.tag_lower('DEBUG')

    text.pack(fill='both')

    text.subcmd('insert', 'end', "ERROR: This is an error\n")
    text.tag_add('ERROR', 1.0, 1.5)
    text.subcmd('insert', 'end', "WARNING: This is a warning\n")
    text.tag_add('WARNING', 2.0, 2.7)
    text.subcmd('insert', 'end', "DEBUG: This is a debug\n")
    text.tag_add('DEBUG', 3.0, 3.5)

    text.subcmd('insert', 'end', str(text.tag_nextrange('ERROR', 1.0, 'end')) + "\n")
    text.subcmd('insert', 'end', str(text.tag_nextrange('WARNING', 1.0, 'end')) + "\n")
    text.subcmd('insert', 'end', str(text.tag_nextrange('DEBUG', 1.0, 'end')) + "\n")

    _print(text, str(text.tag_nextrange('ERROR', 'end', 1.0)) + "\n")
    _print(text, str(text.tag_nextrange('WARNING', 'end', 1.0)) + "\n")
    _print(text, str(text.tag_nextrange('DEBUG', 'end', 1.0)) + "\n")

    _print(text, text.tag_names())

    text.tag_delete('ERROR', 'WARNING', 'DEBUG')

    text.tag_bind('CLICKME', '<Double-1>', lambda e: print('Clicked'))
    text.tag_add('CLICKME', 4.0, '4.0 lineend')

    root.mainloop()
