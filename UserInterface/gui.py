from doctest import script_from_examples
from msilib import Table
from tkinter import *
from tkinter import ttk
from tkinter.messagebox import showinfo
from turtle import left, width
# from ssh_wrapper import *

def main():
    class FailBool:
        def __init__(self, status):
            self.status = status

    #created Tkinter object called root
    root = Tk()
    
    #sets title and size of window
    root.title("KeyLimePi")
    root.geometry('400x400')

    
    #creates login page and fail bool
    f1 = FailBool(False)
    login(root, f1)   

    # runs GUI program
    root.mainloop()

def login(root, f1):
    lbl = Label(root, text="Enter your KeyLimePi password:")
    lbl.pack(ipady=40)

    piPass = Entry(root, width=30)
    piPass.pack()

    # runs when 'enter' key is pressed
    def enter(e):
        # if init_session():
            unpack()
        # if not f1.status:
        #     failed = Label(root, text="The password was incorrect.", fg='red')
        #     failed.pack()
        # retry()
    root.bind('<Return>', enter)

    # runs when button is clicked
    def clicked():
        # if init_session():
            unpack()
        # if not f1.status:
        #     failed = Label(root, text="The password was incorrect.", fg='red')
        #     failed.pack()
        # retry()
    btn = Button(root, text="Enter", command=clicked)
    btn.pack(pady=40, ipadx=40)

    def retry():
        # IF PASSWORD IS CORRECT, LOAD NEW PAGE
        f1.status = True
        lbl.pack_forget()
        piPass.pack_forget()
        btn.pack_forget()
        login(root, f1)

    def unpack():
        # IF PASSWORD IS CORRECT, LOAD NEW PAGE
        lbl.pack_forget()
        piPass.pack_forget()
        btn.pack_forget()
        # failed.unpack()
        mainPage(root)

def mainPage(root):    
    root.unbind('<Return>')
    lbl = Label(root, text="Welcome to KeyLimePi Password Manager!")
    lbl.pack(pady=10)

    def clickNewPass():
        lbl.config(text="new pass")

    def clickGetPass():
        lbl.config(text="get pass")

    def clickEditPass():
        lbl.config(text="edit pass")

    def clickChangePiPass():
        lbl.config(text="change pi pass")

    frame = Frame(root)    
    ttk.Button(frame, text='Create new password', command=clickNewPass).grid(column=0, row=0, padx=10)
    ttk.Button(frame, text='Get password', command=clickGetPass).grid(column=1, row=0, padx=10)    
    ttk.Button(frame, text='Change KeyLimePi password', command=clickGetPass).grid(column=0, row=1, padx=10)    
    ttk.Button(frame, text='Edit password', command=clickGetPass).grid(column=1, row=1, padx=10)    
    frame.pack(side=TOP, pady=10)
    
    langs = ('Java', 'C#', 'C', 'C++', 'Python', 'C', 'C', 'C', 'C', 'C', 'C', 'C', 'C', 'C', 'C', 'C', 'C', 'C' )
    var = Variable(value=langs)
    listbox = Listbox(root, listvariable=var, height=6, selectmode=SINGLE)
    listbox.pack(expand=True, fill=BOTH, side=LEFT, pady=20, padx=20)
    
    scrollbar = Scrollbar(root, orient=VERTICAL, command=listbox.yview)
    listbox['yscrollcommand'] = scrollbar.set
    scrollbar.pack(expand=True, fill=Y, pady=20, ipadx=3, padx=20)

    def items_selected(event):
        selected_indices = listbox.curselection()
        selected_langs = ",".join([listbox.get(i) for i in selected_indices])
        msg = f'You selected: {selected_langs}'
        showinfo(title='Information', message=msg)

    listbox.bind('<<ListboxSelect>>', items_selected)

    

if __name__ == "__main__":
    main()