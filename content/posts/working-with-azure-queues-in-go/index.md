+++
date = "2019-09-29T20:49:40-06:00"
title = "Working with Azure Queues in Go"
description = "Quick snippets to read/write/clear Azure Queues in Golang"
categories = "Software"
tags = ["Go", "Application Development", "Azure"]
+++

I recently needed to write to an Azure Queue in Golang but I struggled to find a quick and simple example so here are some snippets you can use for your needs.

# Include the SDK

```golang
import (
  "context"
  "fmt"
  "log"
  "net/url"
  "time"

  "github.com/Azure/azure-storage-queue-go/azqueue"
)
```

# Setup SDK authentication via Connection String

```golang
storageAccountName := "StorageAccount"
storageAccountKey  := "StorageAccountConnectionString"
storageQueueName   := "StorageQueueName"

_url, err := url.Parse(fmt.Sprintf("https://%s.queue.core.windows.net/%s", storageAccountName, storageQueueName))
if err != nil {
  log.Fatal("Error parsing url: ", err)
}

credential, err := azqueue.NewSharedKeyCredential(storageAccountName, storageAccountKey)
if err != nil {
  log.Fatal("Error creating credentials: ", err)
}
```

# Create queue and or check message count

```golang
queueUrl := azqueue.NewQueueURL(*_url, azqueue.NewPipeline(credential, azqueue.PipelineOptions{}))

ctx := context.TODO()

props, err := queueUrl.GetProperties(ctx)
if err != nil {
  // https://godoc.org/github.com/Azure/azure-storage-queue-go/azqueue#StorageErrorCodeType
  errorType := err.(azqueue.StorageError).ServiceCode()

  if (errorType == azqueue.ServiceCodeQueueNotFound) {

    log.Print("Queue does not exist, creating")

    _, err = queueUrl.Create(ctx, azqueue.Metadata{})
    if err != nil {
        log.Fatal("Error creating queue: ", err)
    }

    props, err = queueUrl.GetProperties(ctx)
    if err != nil {
      log.Fatal("Error parsing url: ", err)
    }

  } else {
    log.Fatal("Error getting queue properties: ", err)
  }
}

messageCount := props.ApproximateMessagesCount()
log.Printf("Appx number of messages: %d", messageCount)
```

# Peek queue messages

```golang
msgUrl := queueUrl.NewMessagesURL()

if messageCount > 0 {

  // (MessagesURL) Peek(context, maxMessages) (*PeekedMessagesResponse, error)
  peekResp, err := msgUrl.Peek(ctx, 32)
  if err != nil {
    log.Fatal("Error peeking queue messages: ", err)
  }

  log.Printf("Peeked Number of Messages: %d", peekResp.NumMessages())

  for i := int32(0); i < peekResp.NumMessages(); i++ {
    msg := peekResp.Message(i)
    log.Printf("%v: {%v} - %v", i, msg.ID.String(), msg.Text)
  }

}
```

# Insert queue messages

```golang
newMessageContent := fmt.Sprintf("Hello world at %v", time.Now().Format(time.RFC3339))

// (MessagesURL) Enqueue(context, messageText, visibilityTimeout, timeToLive) (*EnqueueMessageResponse, error)
_, err = msgUrl.Enqueue(ctx, newMessageContent, 0, 0)
if err != nil {
  log.Fatal("Error adding message to queue: ", err)
}

log.Printf("Added message \"%v\" to the queue", newMessageContent)
```

# Pop queue messages

```golang
// (MessagesURL) Dequeue(context, maxMessages, visibilityTimeout) (*DequeuedMessagesResponse, error)
dequeueResp, err := msgUrl.Dequeue(ctx, 32, 10*time.Second)

if err != nil {
  log.Fatal("Error dequeueing message: ", err)
}

for i := int32(0); i < dequeueResp.NumMessages(); i++ {

  msg := dequeueResp.Message(i)
  log.Printf("Deleting %v: {%v}", i, msg.Text)

  msgIdUrl := msgUrl.NewMessageIDURL(msg.ID)

  // PopReciept is required to delete the Message. If deletion fails using this popreceipt then the message has been dequeued by another client.
  _, err = msgIdUrl.Delete(ctx, msg.PopReceipt)
  if err != nil {
    log.Fatal("Error deleting message: ", err)
  }
}
```