from distutils.cmd import Command
from doctest import script_from_examples
from msilib import Table
from tkinter import *
from tkinter import ttk
from tkinter.messagebox import showinfo, askokcancel
from turtle import left, width
from venv import create
# from ssh_wrapper import *
from uart.py import *

def main():
    class FailBool:
        def __init__(self, status):
            self.status = status

    #created Tkinter object called root
    root = Tk()
    
    def on_closing():
        if askokcancel("Quit", "Do you want to quit?"):
            root.destroy()

    #sets title and size of window
    root.title("KeyLimePi")
    root.geometry('400x400')

    #creates login page and fail bool
    f1 = FailBool(False)
    login(root, f1)   

    # runs GUI program
    root.protocol("WM_DELETE_WINDOW", on_closing)
    root.mainloop()

def login(root, f1):
    lbl = Label(root, text="Enter your KeyLimePi password:")
    lbl.pack(ipady=40)

    piPass = Entry(root, width=30)
    piPass.pack()

    failed = Label(root, text="The password was incorrect.", fg='red')

    # runs when 'enter' key is pressed
    def enter(e):
        if validateConnection(piPass.get()):
            root.unbind('<Return>')
            unpack()
        if not f1.status:
            # failed = Label(root, text="The password was incorrect.", fg='red')
            failed.pack()
        retry()
    root.bind('<Return>', enter)

    # runs when button is clicked
    def clicked():
        if validateConnection(piPass.get()):
            root.unbind('<Return>')
            unpack()
        if not f1.status:
            
            failed.pack()
        retry()
    btn = Button(root, text="Enter", command=clicked)
    btn.pack(pady=40, ipadx=40)

    def retry():
        # IF PASSWORD IS INCORRECT, RELOAD
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
        if not f1.status:
            failed.pack_forget()
        mainPage(root)

def mainPage(root):
    lbl = Label(root, text="Welcome to KeyLimePi Password Manager!")
    lbl.pack(pady=10)

    def makeNewPass(given_user, given_pass, given_site, top):
        createPassword(given_user, given_pass, given_site)
        listbox.insert(END, given_site)
        top.destroy()

    def changeCurrPass(given_pass, given_site, top):
        changePassword(given_pass, given_site)
        top.destroy()

    def clickNewPass():
        top=Toplevel(root)
        top.geometry("450x250")
        top.title("New Password")

        label2 = Label(top, text="New Username:")
        label2.pack(ipady=5)
        newUser = Entry(top, width=30)
        newUser.pack()

        label3 = Label(top, text="New Password:")
        label3.pack(ipady=5)
        newPass = Entry(top, width=30)
        newPass.pack()

        label1 = Label(top, text="New Site:")
        label1.pack(ipady=5)
        newSite = Entry(top, width=30)
        newSite.pack()

        btn = Button(top, text="Add", command=lambda : makeNewPass(newUser.get(), newPass.get(), newSite.get(), top))
        btn.pack(pady=10, ipadx=40)

    def clickGetPass():
        showinfo(title='Password', message=listDomainInfo(listbox.get(listbox.curselection())))

    def clickEditPass():
        top=Toplevel(root)
        top.geometry("450x250")
        top.title("Edit Password")

        label = Label(top, text="New Password:")
        label.pack(ipady=40)
        newPass = Entry(top, width=30)
        newPass.pack()

        btn = Button(top, text="Change", command=lambda : changeCurrPass(newPass.get(), listbox.get(listbox.curselection()), top))
        btn.pack(pady=40, ipadx=40)

    def clickDelPass():
        deleteDomain(listbox.get(listbox.curselection()))
        listbox.delete(listbox.curselection())
        showinfo(message="Password Deleted!")

    # set of buttons inside of frame
    frame = Frame(root)    
    ttk.Button(frame, text='Create new password', command=clickNewPass).grid(column=0, row=0, padx=10)
    ttk.Button(frame, text='Get password', command=clickGetPass).grid(column=1, row=0, padx=10)    
    ttk.Button(frame, text='Edit password', command=clickEditPass).grid(column=1, row=1, padx=10)
    ttk.Button(frame, text='Delete password', command=clickDelPass).grid(column=0, row=1, padx=10)
    frame.pack(side=TOP, pady=10)
    
    # list object
    # langs = ('Java', 'C#', 'C', 'C++', 'Python', 'C', 'C', 'C', 'C', 'C', 'C', 'C', 'C', 'C', 'C', 'C', 'C', 'C' )
    domains = listDomains()
    var = Variable(value=domains)
    listbox = Listbox(root, listvariable=var, height=6, selectmode=SINGLE)
    listbox.pack(expand=True, fill=BOTH, side=LEFT, pady=20, padx=20)
    
    # list scrollbar object
    scrollbar = Scrollbar(root, orient=VERTICAL, command=listbox.yview)
    listbox['yscrollcommand'] = scrollbar.set
    scrollbar.pack(expand=True, fill=Y, pady=20, ipadx=3, padx=20)

    def items_selected(event):
        selected_indices = listbox.curselection()
        selected_langs = ",".join([listbox.get(i) for i in selected_indices])
        msg = f'You selected: {selected_langs}'
        showinfo(title='Information', message=msg)    

if __name__ == "__main__":
    main()