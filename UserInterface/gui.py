from tkinter import *
from tkinter import ttk
# from ssh_wrapper import *

def main():
    #created Tkinter object called root
    root = Tk()
    
    #sets title and size of window
    root.title("KeyLimePi")
    root.geometry('400x250')

    #creates login page
    class FailBool:
        def __init__(self, status):
            self.status = status
    
    f1 = FailBool(False)
    login(root, f1)   

    # runs GUI program
    root.mainloop()

def login(root, f1):
    lbl = Label(root, text="Enter your KeyLimePi password:")
    lbl.pack(ipady=40)

    piPass = Entry(root, width=10)
    piPass.pack()

    # runs when 'enter' key is pressed
    def enter(e):
        # if init_session():
        #     unpack()
        if not f1.status:
            failed = Label(root, text="The password was incorrect.", fg='red')
            failed.pack()
        retry()
    root.bind('<Return>', enter)

    # runs when button is clicked
    def clicked():
        # if init_session():
        #     unpack()
        if not f1.status:
            failed = Label(root, text="The password was incorrect.", fg='red')
            failed.pack()
        retry()
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
        mainPage(root)

def mainPage(root):
    lbl = Label(root, text="Welcome to KeyLimePi Password Manager!")
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