/**
 * Upload Service - Handles file uploads for documents and media
 */
service UploadService @(path: '/odata/v4/upload') {
  
  // Custom actions for file uploads
  action uploadImportDocument(
    shipmentID : UUID,
    documentType : String,
    fileName : String,
    fileSize : Integer,
    mimeType : String,
    fileContent : LargeBinary
  ) returns {
    documentID : UUID;
    fileUrl : String;
    success : Boolean;
    message : String;
  };
  
  action uploadProofOfDelivery(
    deliveryID : UUID,
    fileType : String, // "signature" or "photo"
    fileName : String,
    fileContent : LargeBinary
  ) returns {
    fileUrl : String;
    success : Boolean;
    message : String;
  };
  
  action uploadProductImage(
    productID : UUID,
    imageType : String, // "main" or "thumbnail"
    fileName : String,
    fileContent : LargeBinary
  ) returns {
    imageUrl : String;
    success : Boolean;
    message : String;
  };
  
  // File retrieval
  function getFile(fileUrl : String) returns LargeBinary;
  function deleteFile(fileUrl : String) returns Boolean;
}
