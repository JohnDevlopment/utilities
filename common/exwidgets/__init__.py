"""Wrapper functions for Tcl package "tk_widgets".

Example:
root = Tk()
entry = ExEntry(root)
"""

import _tkinter
from tkinter import Tk, CallWrapper, _cnfmerge, _stringify, \
    _get_default_root, _flatten, _get_default_root as get_default_root, getboolean
from tkinter.ttk import _val_or_dict

TclError = _tkinter.TclError

packageLoaded = False

__all__ = ['ExWidget', 'Pack', 'Grid', 'TkBusyCommand']

class Pack:
    """Geometry manager pack.

    Base class to use the pack method in any widget.
    """

    def pack(self, cnf={}, **kwargs):
        """Pack the widget in the parent widget using exw pack.

        Options include:
            after=widget - pack it after you have packed widget
            anchor=NSEW (or subset) - position widget according to given direction
            before=widget - pack it before you will pack widget
            expand=bool - expand widget if parent size grows
            fill=NONE or X or Y or BOTH - fill widget if widget grows
            in=master - use master to contain this widget
            in_=master - see 'in' option description
            ipadx=amount - add internal padding in x direction
            ipady=amount - add internal padding in y direction
            padx=amount - add padding in x direction
            pady=amount - add padding in y direction
            side=TOP or BOTTOM or LEFT or RIGHT -  where to add this widget.
        """
        self._tk.call(
            ('exw', 'pack', self._widget) + self._options(cnf, kwargs)
        )

class Grid:
    """Geometry manager grid.

    Base class to use the grid method in any widget.
    """
    def grid_bbox(self, column=None, row=None, col2=None, row2=None):
        """Return a tuple of integer coordinates for the bounding
        box of this widget controlled by the geometry manager grid.

        If COLUMN, ROW is given the bounding box applies from
        the cell with row and column 0 to the specified
        cell. If COL2 and ROW2 are given the bounding box
        starts at that cell.

        The returned integers specify the offset of the upper left
        corner in the master widget and the width and height.
        """
        args = ('exw', 'grid', 'bbox', self._widget)
        if column is not None and row is not None:
            args = args + (column, row)
        if col2 is not None and row2 is not None:
            args = args + (col2, row2)
        return self._getints(self._tk.call(*args)) or None

    bbox = grid_bbox

    def grid_configure(self, cnf={}, **kwargs):
        """Position a widget in the parent widget in a grid.

        Options include:
            column=number - use cell identified with given column (starting with 0)
            columnspan=number - this widget will span several columns
            in=master - use master to contain this widget
            in_=master - see 'in' option description
            ipadx=amount - add internal padding in x direction
            ipady=amount - add internal padding in y direction
            padx=amount - add padding in x direction
            pady=amount - add padding in y direction
            row=number - use cell identified with given row (starting with 0)
            rowspan=number - this widget will span several rows
            sticky=NSEW - if cell is larger on which sides will this
                          widget stick to the cell boundary
        """
        self._tk.call(
            ('exw', 'grid', self._widget) + self._options(cnf, kwargs))

    grid = grid_configure

class TkBusyCommand:
    """A class representing "tk busy" command.

    Use the hold() and forget() methods to mark a window as busy.

    This class can be instantiated in a 'with' statement: the window is automatically held
    and released.
    """
    def __init__(self, master=None, window=None):
        """Construct a TkBusyCommand object.

        Arguments
            MASTER is the Tk master of this class. If omitted,
            it defaults to the root window.
        
            WINDOW is the Widget that you intend to mark as busy.
            It omitted, it defaults to MASTER.
        """
        if master is None:
            master = get_default_root('get master for busy command')
        self._root = master
        self._tk = self._root.tk
        self._widget = window or master

    def forget(self):
        """Releases the busy-hold on the widget and its descendents."""
        if self._is_busy():
            self._tk.call('tk', 'busy', 'forget', self._widget)
            self._tk.call('update')

    def hold(self):
        """Makes the window appear busy."""
        if not self._is_busy():
            self._tk.call('tk', 'busy', 'hold', self._widget)
            self._tk.call('update')

    @property
    def is_busy(self):
        """True if the window is busy."""
        return self._is_busy()

    def _is_busy(self):
        return getboolean(self._tk.call('tk', 'busy', 'status', self._widget))

    def __enter__(self):
        """Called when TkBusyCommand is instanced in a with statement.

        Calls hold().
        """
        self.hold()
        return self

    def __exit__(self, *args):
        """Called at the end of a with statement.

        Calls forget().
        """
        self.forget()

class ExWidget:
    """Base class for extended widgets."""

    # Use self._tk.call to use raw Tcl commands

    _options = Tk._options
    _substitute = Tk._substitute
    _subst_format_str = Tk._subst_format_str
    _subst_format = Tk._subst_format

    def __init__(self, master, cnf={}, kw={}):
        # NOTE: Used for its call() method
        if master is None:
            master = _get_default_root("instance a widget")
        self._tk = master.tk
        self._tclCommands = []

        if kw:
            cnf = _cnfmerge((cnf, kw))

        self._widget = None
        self._master = master

        classes = [(k, v) for k, v in cnf.items() if isinstance(k, type)]
        for k, v in classes:
            del cnf[k]

        self.cnf = cnf

        # Load package only once
        global packageLoaded
        if not packageLoaded:
            try:
                self._tk.call('package', 'require', 'tk_widgets')
            except TclError as exc:
                raise RuntimeError(str(exc))
            self._tk.call('set', '::exWidgets::python', True)
            packageLoaded = True

    def bind(self, sequence=None, func=None, add=None):
        """Bind to this widget at event SEQUENCE a call to function FUNC.

        SEQUENCE is a string of concatenated event
        patterns. An event pattern is of the form
        <MODIFIER-MODIFIER-TYPE-DETAIL> where MODIFIER is one
        of Control, Mod2, M2, Shift, Mod3, M3, Lock, Mod4, M4,
        Button1, B1, Mod5, M5 Button2, B2, Meta, M, Button3,
        B3, Alt, Button4, B4, Double, Button5, B5 Triple,
        Mod1, M1. TYPE is one of Activate, Enter, Map,
        ButtonPress, Button, Expose, Motion, ButtonRelease
        FocusIn, MouseWheel, Circulate, FocusOut, Property,
        Colormap, Gravity Reparent, Configure, KeyPress, Key,
        Unmap, Deactivate, KeyRelease Visibility, Destroy,
        Leave and DETAIL is the button number for ButtonPress,
        ButtonRelease and DETAIL is the Keysym for KeyPress and
        KeyRelease. Examples are
        <Control-Button-1> for pressing Control and mouse button 1 or
        <Alt-A> for pressing A and the Alt key (KeyPress can be omitted).
        An event pattern can also be a virtual event of the form
        <<AString>> where AString can be arbitrary. This
        event can be generated by event_generate.
        If events are concatenated they must appear shortly
        after each other.

        FUNC will be called if the event sequence occurs with an
        instance of Event as argument. If the return value of FUNC is
        "break" no further bound function is invoked.

        An additional boolean parameter ADD specifies whether FUNC will
        be called additionally to the other bound function or whether
        it will replace the previous function.

        Bind will return an identifier to allow deletion of the bound function with
        unbind without memory leak.

        If FUNC or SEQUENCE is omitted the bound function or list
        of bound events are returned.
        """
        return self._widget._bind(('exw', 'bind', self._widget), sequence, func, add)

    def deletecommand(self, name: str):
        """Internal function.

        Delete the Tcl command provided by NAME.
        """
        self._tk.deletecommand(name)
        try:
            self._tclcommands.remove(name)
        except ValueError:
            pass

    def focus_displayof(self):
        """Returns the widget that has the focus on the same display as this widget.

        Returns None if the application does not have the focus.
        """
        name = self._tk.call('exw', 'focus', '-displayof', self._widget)
        if name == 'none' or not name:
            return None
        return self._widget.nametowidget(name)

    def focus_force(self):
        """Direct input focus to this widget even if the application does not
        have the focus.

        This command should be used sparingly, if at all. In normal usage,
        an application should not claim the focus for itself; instead it should wait
        to get the focus from the window manager.
        """
        self._tk.call('exw', 'focus', '-force', self._widget)

    def focus_lastfor(self):
        """Returns the widget which would have the focus if the top level for this
        widget gets the focus from the window manager."""
        name = self._tk.call('exw', 'focus', '-lastfor', self._widget)
        if name == 'none' or not name:
            return None
        return self._widget.nametowidget(name)

    def focus_set(self):
        """Direct input focus to this widget.

        If the application currently does not have the focus
        this widget will get the focus if the application gets the
        focus through the window manager.
        """
        self._tk.call('exw', 'focus', self._widget)

    focus = focus_set

    def instate(self, stateSpec, callback=None, *args, **kwargs):
        """Test the widget's state.

        If CALLBACK is not specified, returns true if the widget state
        matches STATESPEC. If CALLBACK is specified, then it will be invoked
        if the widget state matches STATESPEC with *ARGS and **KWARGS.
        STATESPEC is expected to be a sequence.
        """
        ret = self._tk.getboolean(
            self._tk.call('exw', 'instate', self._widget, ' '.join(statespec)))
        if ret and callback is not None:
            return callback(*args, **kwargs)

        return ret

    @property
    def master(self):
        """The widget's master."""
        return self._master

    def state(self, stateSpec=None):
        """Modify the widget's state.

        Widget state is returned if STATESPEC is None, otherwise it is set
        according to the rules outlined below. The returned value follows the same
        rules as STATESPEC.

        STATESPEC Rules
            If the underlying widget is a ttk widget, then STATESPEC is
            a sequence of statespec flags, but for non-ttk widgets STATESPEC is
            either 'normal' or 'disabled'.
        """
        if isinstance(stateSpec, (list, tuple)):
            stateSpec = ' '.join(stateSpec)
        
        return self._tk.splitlist(
            self._tk.call('exw', 'state', self._widget, stateSpec))

    def subcmd(self, cmd: str, *args):
        """Calls one of the widget's commands.

        Said command can be one of the standard commands supplied by Tk or one of the
        extended widget commands.
        """
        res = self._tk.call('exw', 'subcmd', self._widget, cmd, *args)
        if isinstance(res, _tkinter.Tcl_Obj):
            res = str(res)
        return res

    def unbind(self, sequence, funcid=None):
        """Unbind for this widget for event SEQUENCE the
        function identified with FUNCID."""
        self._tk.call('exw', 'bind', self._widget, sequence, '')
        if funcid:
            self.deletecommand(funcid)

    def _bind(self, what, sequence, func, add, needcleanup=1):
        """Internal function."""
        if isinstance(func, str):
            self._tk.call(what + (sequence, func))
        elif func:
            funcid = self._register(func, self._substitute,
                        needcleanup)
            cmd = ('%sif {"[%s %s]" == "break"} break\n'
                   %
                   (add and '+' or '',
                funcid, self._subst_format_str))
            self._tk.call(what + (sequence, cmd))
            return funcid
        elif sequence:
            return self._tk.call(what + (sequence,))
        else:
            return self._tk.splitlist(self._tk.call(what))

    def _configure(self, cmd, cnf, kw):
        """Internal function."""
        if kw:
            cnf = _cnfmerge((cnf, kw))
        elif cnf:
            cnf = _cnfmerge(cnf)
        if cnf is None:
            return self._getconfigure(
                _flatten(('exw', 'subcmd', self._widget, cmd)))
        if isinstance(cnf, str):
            return self._getconfigure(
                _flatten(('exw', 'subcmd', self._widget, cmd, '-'+cnf)))
        self._tk.call(
            _flatten(('exw', 'subcmd', self._widget, cmd)) + self._options(cnf))

    def _getconfigure(self, *args):
        """Internal function."""
        x = self._tk.splitlist(self._tk.call(*args))
        return (x[0][1:],) + x[1:]

    def _options(self, cnf, kw=None):
        """Internal function."""
        if kw:
            cnf = _cnfmerge((cnf, kw))
        else:
            cnf = _cnfmerge(cnf)
        res = ()
        for k, v in cnf.items():
            if v is not None:
                if k[-1] == '_': k = k[:-1]
                if callable(v):
                    v = self._register(v)
                elif isinstance(v, (tuple, list)):
                    nv = []
                    for item in v:
                        if isinstance(item, int):
                            nv.append(str(item))
                        elif isinstance(item, str):
                            nv.append(_stringify(item))
                        else:
                            break
                    else:
                        v = ' '.join(nv)
                elif isinstance(v, bool):
                    if v:
                        res = res + ('-'+k,)
                        continue
                res = res + ('-'+k, v)
        return res

    def _register(self, func, subst=None, needcleanup=1):
        """Return a newly created Tcl function. If this
        function is called, the Python function FUNC will
        be executed. An optional function SUBST can
        be given which will be executed before FUNC."""
        f = CallWrapper(func, subst, self).__call__
        name = repr(id(f))

        try:
            func = func.__func__
        except AttributeError:
            pass

        try:
            name = name + func.__name__
        except AttributeError:
            pass

        self._tk.createcommand(name, f)

        if needcleanup:
            if self._tclCommands is None:
                self._tclCommands = []
            self._tclCommands.append(name)

        return name

    def _report_exception(self):
        """Internal function."""
        self._widget._report_exception()

    def __str__(self) -> str:
        """Returns the string path of the widget."""
        return self._widget._w
