from tkinter import *
from tkinter import ttk

def main():
    #created Tkinter object called root
    root = Tk()

    #TESTING THINGS FROM TKINTER SITE
    # frm = ttk.Frame(root, padding=10)
    # frm.grid()
    # ttk.Label(frm, text="Hello World!").grid(column=0, row=0)
    # ttk.Button(frm, text="Quit", command=root.destroy).grid(column=1, row=1)
    
    #sets title and size of window
    root.title("PasswordKeyLymePi")
    root.geometry('400x200')

    menu = Menu(root)
    item = Menu(menu)
    item.add_command(label="New")
    menu.add_cascade(label="File", menu=item)
    root.config(menu=menu)

    lbl = Label(root, text = "Whar?")
    lbl.pack(ipady=40)

    txt = Entry(root, width=10)
    txt.pack()

    def clicked(e):
        res = "You wrote " + txt.get()
        lbl.configure(text = res)

    btn = Button(root, text = "Click Here!", fg = "red", command=clicked)
    btn.pack(pady=40, ipadx=40)
    root.bind('<Return>', clicked)
    #runs GUI program
    root.mainloop()

if __name__ == "__main__":
    main()