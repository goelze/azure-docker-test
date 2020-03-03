using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Azure.Storage;
using Microsoft.Azure.Storage.Blob;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace AzureDockerTest
{
    public class FileHostedService : IHostedService
    {
        readonly ILogger<FileHostedService> _logger;
        readonly CloudBlobContainer _container;
        readonly string _appendBlobFileName;

        public FileHostedService(ILogger<FileHostedService> logger, IConfiguration configuration)
        {
            _logger = logger;
            _container = CloudStorageAccount.Parse(configuration["BlobStorageConnection"])
                .CreateCloudBlobClient()
                .GetContainerReference(configuration["BlobContainerName"]);
            _appendBlobFileName = configuration["AppendBlobFileName"];
        }

        public async Task StartAsync(CancellationToken cancellationToken)
        {
            _logger.LogInformation("Starting!");

            await _container.CreateIfNotExistsAsync(cancellationToken);

            CloudAppendBlob blob = _container.GetAppendBlobReference(_appendBlobFileName);
            if (!await blob.ExistsAsync(cancellationToken))
            {
                await blob.UploadTextAsync(_appendBlobFileName + "\n", cancellationToken);
                blob.Properties.ContentType = "text/plain";
                await blob.SetPropertiesAsync(cancellationToken);
            }

            await blob.AppendTextAsync($"Started {DateTime.UtcNow:G}\n", cancellationToken);
        }

        public async Task StopAsync(CancellationToken cancellationToken)
        {
            _logger.LogInformation("Stopping!");

            CloudAppendBlob blob = _container.GetAppendBlobReference(_appendBlobFileName);
            await blob.AppendTextAsync($"Ended {DateTime.UtcNow:G}\n", cancellationToken);
        }
    }
}
