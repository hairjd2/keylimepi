from tkinter import *
from tkinter import ttk
from ssh_wrapper import *

def main():
    #created Tkinter object called root
    root = Tk()
    
    #sets title and size of window
    root.title("KeyLymePi")
    root.geometry('400x250')

    #creates login page
    login(root)   

    # runs GUI program
    root.mainloop()

def login(root):
    lbl = Label(root, text="Enter your KeyLymePi password:")
    lbl.pack(ipady=40)

    piPass = Entry(root, width=10)
    piPass.pack()

    # runs when 'enter' key is pressed
    def enter(e):
        if init_session():
            unpack()
        failed = Label(root, text="The password was incorrect.", fg='red')
        failed.pack()
        retry()
    root.bind('<Return>', enter)

    # runs when button is clicked
    def clicked():

        unpack()
    btn = Button(root, text="Enter", command=clicked)
    btn.pack(pady=40, ipadx=40)

    def retry():
        # IF PASSWORD IS CORRECT, LOAD NEW PAGE
        lbl.pack_forget()
        piPass.pack_forget()
        btn.pack_forget()
        login(root)

    def unpack():
        # IF PASSWORD IS CORRECT, LOAD NEW PAGE
        lbl.pack_forget()
        piPass.pack_forget()
        btn.pack_forget()
        mainPage(root)

def mainPage(root):
    lbl = Label(root, text="Welcome to KeyLymePi Password Manager!")
    lbl.pack(ipady=40)

    def clickNewPass():
        lbl.config(text="new pass")
    btn = Button(root, text="Enter", command=clickNewPass)
    btn.pack(pady=40, ipadx=40)

    def clickGetPass():
        lbl.config(text="new pass")
    btn = Button(root, text="Enter", command=clickGetPass)
    btn.pack(pady=40, ipadx=40) 

if __name__ == "__main__":
    main()