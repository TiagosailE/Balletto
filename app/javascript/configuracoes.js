function initPreviewFoto() {
  const fotoInput = document.getElementById('user_foto');
  const previewFoto = document.getElementById('preview-foto');
  const filenameDisplay = document.getElementById('filename-display');
  
  console.log('🔍 Procurando elementos...', { fotoInput, previewFoto, filenameDisplay });
  
  if (fotoInput && previewFoto) {
    console.log('✅ Elementos encontrados, adicionando listener');
    
    fotoInput.addEventListener('change', function(e) {
      const file = e.target.files[0];
      console.log('📁 Arquivo selecionado:', file);

      if (filenameDisplay) {
        const fileName = file?.name || 'Nenhum arquivo selecionado';
        filenameDisplay.textContent = fileName;
      }
      
      if (file && file.type.startsWith('image/')) {
        console.log('✅ É uma imagem válida');
        const reader = new FileReader();
        
        reader.onload = function(e) {
          console.log('✅ Imagem carregada, atualizando preview');
          
          if (previewFoto.tagName === 'IMG') {
            previewFoto.src = e.target.result;
          } else {
            const img = document.createElement('img');
            img.src = e.target.result;
            img.className = 'w-30 h-30 rounded-full object-cover border-4 border-[#C5A300] shadow-lg';
            img.id = 'preview-foto';
            previewFoto.replaceWith(img);
          }
        };
        
        reader.readAsDataURL(file);
      } else {
        console.log('❌ Não é uma imagem válida');
      }
    });
  } else {
    console.log('❌ Elementos não encontrados');
  }
}

document.addEventListener('turbo:load', initPreviewFoto);
document.addEventListener('DOMContentLoaded', initPreviewFoto);
