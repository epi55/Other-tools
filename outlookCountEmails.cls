' Note: Dim = "dimension", used to declare variables.
' Dim name As String = declare variable "name" as a "String" type (to be stored later)

' Note: Sub = "procedure", used like a function (but will not "return" a value or be used in an expression)
' Sub CreateReport (ByVal ReportDate As Datee)

Sub CountEmailsPerDay()
    ' This is the name of the procedure that you can run to execute the code
    Dim objOutlook As Object, objnSpace As Object
    ' This declares two variables to store Outlook objects
    Dim objInbox As MAPIFolder, objSent As MAPIFolder
    ' This declares two variables to store the Inbox and Sent Items folders
    Dim EmailCount As Integer, DateCount As Integer, iCount As Integer
    ' This declares three variables to store some counts, but they are not used in the code
    Dim myDate As Date
    ' This declares a variable to store the date of an email
    Dim myItems As Outlook.Items
    ' This declares a variable to store a collection of Outlook items
    Dim dict As Object
    ' This declares a variable to store a dictionary object
    Dim msg As String
    ' This declares a variable to store a message string
    Dim csv As String
    ' This declares a variable to store a csv string
    Dim sender As String
    ' This declares a variable to store the sender of an email, but it is not used in the code
    
    Set objOutlook = CreateObject("Outlook.Application")
    ' This creates an instance of the Outlook application and assigns it to the objOutlook variable
    Set objnSpace = objOutlook.GetNamespace("MAPI")
    ' This gets the MAPI namespace from the Outlook application and assigns it to the objnSpace variable
    ' MAPI stands for Messaging Application Programming Interface, which is a way to access Outlook data[^2^][2]
    
    ' Get Inbox and Sent Items folders
    Set objInbox = objnSpace.GetDefaultFolder(olFolderInbox)
    ' This gets the default Inbox folder from the MAPI namespace and assigns it to the objInbox variable
    Set objSent = objnSpace.GetDefaultFolder(olFolderSentMail)
    ' This gets the default Sent Items folder from the MAPI namespace and assigns it to the objSent variable
    
    ' Create a dictionary object to store the counts
    Set dict = CreateObject("Scripting.Dictionary")
    ' This creates an instance of the dictionary object and assigns it to the dict variable
    ' A dictionary is a collection of key-value pairs that can be used to store and retrieve data[^3^][3]
    
    ' Loop through the items in Inbox and Sent Items folders
    For Each objFolder In Array(objInbox, objSent)
        ' This starts a loop that iterates over the two folders stored in an array
        Set myItems = objFolder.Items
        ' This gets the items (such as emails) from the current folder and assigns them to the myItems variable
        myItems.SetColumns ("SentOn") ' Optimize the performance
        ' This sets the columns of the items to only include the SentOn property, which is the date and time when the email was sent
        ' This is done to optimize the performance of the loop by reducing the amount of data to process
        For Each myItem In myItems
            ' This starts another loop that iterates over the items in the current folder
            ' Get the date of the item
            myDate = DateSerial(Year(myItem.SentOn), Month(myItem.SentOn), Day(myItem.SentOn))
            ' This gets the year, month, and day of the SentOn property of the current item and converts them to a date value
            ' This is done to ignore the time part of the SentOn property and group the emails by date
            ' Initialize the counts for the date
            If Not dict.Exists(myDate) Then
                ' This checks if the dictionary does not have a key for the current date
                dict(myDate) = Array(0, 0) ' First element is sent count, second element is received count
                ' This creates an array of two elements, both initialized to zero, and assigns it to the dictionary with the current date as the key
                ' The first element of the array will store the number of emails sent on that date
                ' The second element of the array will store the number of emails received on that date
            End If
            ' Increment the count for the date based on the class of the item
            If myItem.Class = olMail Then ' Mail item
                ' This checks if the class of the current item is olMail, which means it is a mail item (such as an email)
                Debug.Print TypeName(myItem) ' TEST
                ' This prints the type name of the current item to the Immediate window for testing purposes
                Debug.Print myItem.sender ' TEST
                ' This prints the sender of the current item to the Immediate window for testing purposes
                If myItem.sender Is Nothing Then ' Sent email
                    ' This checks if the sender of the current item is Nothing, which means it is a sent email
                    dict(myDate)(0) = CLng(dict(myDate)(0)) + 1
                    ' This converts the first element of the array stored in the dictionary for the current date to a long integer and increments it by one
                    ' This is done to update the count of emails sent on that date
                Else ' Received email
                    ' This means the sender of the current item is not Nothing, which means it is a received email
                    dict(myDate)(1) = CLng(dict(myDate)(1)) + 1
                    ' This converts the second element of the array stored in the dictionary for the current date to a long integer and increments it by one
                    ' This is done to update the count of emails received on that date
                End If
            End If
        Next myItem
        ' This ends the inner loop and moves to the next item in the current folder
    Next objFolder
    ' This ends the outer loop and moves to the next folder in the array
    
    ' Output the counts per day
    msg = ""
    ' This initializes the msg variable to an empty string
    csv = "Date,Sent,Received" & vbCrLf
    ' This initializes the csv variable to a string that contains the headers for the csv file, separated by commas, and a line break
    ' vbCrLf is a constant that represents a carriage return and a line feed, which are characters used to start a new line
    For Each o In dict.Keys
        ' This starts a loop that iterates over the keys of the dictionary, which are the dates
        msg = msg & o & ": " & dict(o)(0) & " sent, " & dict(o)(1) & " received" & vbCrLf
        ' This concatenates the current key (date), a colon, a space, the first element of the array stored in the dictionary for that key (sent count), a space, the word "sent", a comma, a space, the second element of the array stored in the dictionary for that key (received count), a space, the word "received", and a line break to the msg variable
        ' This is done to build the message string that will show the counts per day in a readable format
        csv = csv & o & "," & dict(o)(0) & "," & dict(o)(1) & vbCrLf
        ' This concatenates the current key (date), a comma, the first element of the array stored in the dictionary for that key (sent count), a comma, the second element of the array stored in the dictionary for that key (received count), and a line break to the csv variable
        ' This is done to build the csv string that will store the counts per day in a comma-separated format
    Next
    
    ' Show the counts in a message box
    MsgBox msg
    ' This displays the msg variable in a message box, which is a dialog box that shows a message and waits for the user to click a button
    
    ' Save the counts to a CSV file
    Dim fso As Object
    ' This declares a variable to store a file system object
    Dim file As Object
    ' This declares a variable to store a file object
    Set fso = CreateObject("Scripting.FileSystemObject")
    ' This creates an instance of the file system object and assigns it to the fso variable
    ' A file system object is an object that provides access to the file system, such as creating, reading, or writing files
    Set file = fso.CreateTextFile("C:\Users\YourName\Documents\EmailCount.csv", True)
    ' This creates a text file with the specified path and name and assigns it to the file variable
    ' The second argument is True, which means the file will be overwritten if it already exists
    file.Write csv
    ' This writes the csv variable to the file
    file.Close
    ' This closes the file
    
    ' Clear Outlook objects
    Set objInbox = Nothing
    ' This sets the objInbox variable to Nothing, which means it no longer references the Inbox folder
    Set objSent = Nothing
    ' This sets the objSent variable to Nothing, which means it no longer references the Sent Items folder
    Set objnSpace = Nothing
    ' This sets the objnSpace variable to Nothing, which means it no longer references the MAPI namespace
    Set objOutlook = Nothing
    ' This sets the objOutlook variable to