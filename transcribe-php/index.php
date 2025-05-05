<?php
// Carrega o autoload do Composer (necessário para usar o AWS SDK)
require '../transcribe-php/vendor/autoload.php';

use Aws\TranscribeService\TranscribeServiceClient;


// Instancia o cliente do Amazon Transcribe com credenciais manuais
$client = new TranscribeServiceClient([
    'version' => 'latest',
    'region' => 'us-east-1', // Altere para sua região AWS se necessário
    'credentials' => [
        'key' => '',          // ⚠️ CUIDADO: não é seguro deixar essas credenciais no código
        'secret' => '',
    ]
]);

// Define um nome único para o job de transcrição usando timestamp
$jobName = 'Transcript-job-' . (new DateTime())->getTimestamp();

// Nome do bucket S3 onde o áudio já está hospedado
$bucket = 'general-bucket-julio';

// Caminho do arquivo de áudio no bucket
$fileName = '.wav/piplup.opus'; // ⚠️ Parece estar com uma extensão estranha: ".wav/" indica que pode haver erro

// Inicia o job de transcrição usando a AWS Transcribe
$result = $client->startTranscriptionJob([
    'TranscriptionJobName' => $jobName,
    'LanguageCode' => 'pt-BR', // Define o idioma da transcrição
    'MediaFormat' => 'ogg',    // Formato do áudio (confirme se é esse mesmo)
    'Media' => [
        'MediaFileUri' => "s3://$bucket/$fileName", // URI do arquivo no S3
    ],
    'OutputBucketName' => $bucket, // Onde o resultado será salvo (opcional)
]);

// Aguarda o job terminar consultando a cada 3 segundos
do {
    sleep(3); // Espera 3 segundos entre cada verificação

    $result = $client->getTranscriptionJob([
        'TranscriptionJobName' => $jobName,
    ]);
    // Obtém os status da transcrição
    $status = $result['TranscriptionJob']['TranscriptionJobStatus'];

    // A repetição acontece para cada vez que a transcrição está em progresso
} while ($status === 'IN_PROGRESS');

// Se a transcrição foi concluída com sucesso
if ($status === 'COMPLETED') {

    // Pega a URL para o arquivo JSON com a transcrição
    $uri = $result['TranscriptionJob']['Transcript']['TranscriptFileUri'];

    // Faz o download e decodifica o conteúdo JSON
    $words = json_decode(file_get_contents($uri), false);

    // Exibe a transcrição principal retornada pela AWS Transcribe
    echo '<p>' . print_r($words->results->transcripts[0]->transcript, true) . '</p>';
}
?>
