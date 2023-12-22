Sub CountEmails()
    Dim objFolder As Outlook.MAPIFolder
    Dim objNS As Outlook.NameSpace
    Dim objMail As Outlook.MailItem
    Dim objReport As Outlook.ReportItem
    Dim strReport As String
    Dim intCount As Integer
    Dim intSent As Integer
    Dim intReceived As Integer
    Dim datToday As Date
    Dim datSent As Date
    Dim datReceived As Date
    
    'Set the date to today
    datToday = Date
    
    'Get the Sent Items folder
    Set objNS = Application.GetNamespace("MAPI")
    Set objFolder = objNS.GetDefaultFolder(olFolderSentMail)
    
    'Count the number of sent emails
    For Each objMail In objFolder.Items
        datSent = objMail.SentOn
        If DateValue(datSent) = datToday Then
            intSent = intSent + 1
        End If
    Next objMail
    
    'Get the Inbox folder
    Set objFolder = objNS.GetDefaultFolder(olFolderInbox)
    
    'Count the number of received emails
    For Each objMail In objFolder.Items
        datReceived = objMail.ReceivedTime
        If DateValue(datReceived) = datToday Then
            intReceived = intReceived + 1
        End If
    Next objMail
    
    'Create the report
    strReport = "Number of emails sent today: " & intSent & vbCrLf & _
                "Number of emails received today: " & intReceived
    
    'Create a new report item
    Set objReport = Application.CreateItem(olReportItem)
    
    'Set the subject and body of the report item
    objReport.Subject = "Email Count for " & datToday
    objReport.Body = strReport
    
    'Display the report item
    objReport.Display
    
End Sub