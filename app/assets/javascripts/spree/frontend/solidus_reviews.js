function setupModal(openButtonId, modalId, closeButtonId, fetchUrl = null) {
  document.addEventListener("DOMContentLoaded", () => {
    const openModalButton = document.getElementById(openButtonId);
    const modal = document.getElementById(modalId);
    const closeModalButton = document.getElementById(closeButtonId);
    const modalContent = fetchUrl ? document.getElementById("modalContent") : null;

    if (!openModalButton || !modal || !closeModalButton || (fetchUrl && !modalContent)) {
      console.error("Required modal elements not found!");
      return;
    }

    openModalButton.addEventListener("click", (event) => {
      event.preventDefault();
      if (fetchUrl) {
        fetch(fetchUrl)
          .then((response) => response.text())
          .then((html) => {
            modalContent.innerHTML = html;
            modal.classList.remove("hidden");
          })
          .catch((error) => console.error("Error loading modal content:", error));
      } else {
        modal.classList.remove("hidden");
      }
    });

    closeModalButton.addEventListener("click", () => {
      modal.classList.add("hidden");
      if (modalContent) {
        modalContent.innerHTML = "";
      }
    });

    modal.addEventListener("click", (event) => {
      if (event.target === modal) {
        modal.classList.add("hidden");
        if (modalContent) {
          modalContent.innerHTML = "";
        }
      }
    });

    const handleAjaxSuccess = (event) => {
      const [data, status, xhr] = event.detail;
      if (data.success) {
        modal.classList.add("hidden");
        if (modalContent) {
          modalContent.innerHTML = "";
        }
      }
    };

    const handleAjaxError = (event) => {
      const [data, status, xhr] = event.detail;
      if (xhr.responseText) {
        if (modalContent) {
          modalContent.innerHTML = xhr.responseText;
        }
      }
    };

    document.addEventListener("ajax:success", handleAjaxSuccess);
    document.addEventListener("ajax:error", handleAjaxError);

    closeModalButton.addEventListener("click", () => {
      document.removeEventListener("ajax:success", handleAjaxSuccess);
      document.removeEventListener("ajax:error", handleAjaxError);
    });
  });
}
