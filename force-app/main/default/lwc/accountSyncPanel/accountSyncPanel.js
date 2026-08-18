import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import enqueueSync from "@salesforce/apex/AccountSyncController.enqueueSync";

export default class AccountSyncPanel extends LightningElement {
  @api recordId;

  isLoading = false;
  jobId;

  async handleSync() {
    this.isLoading = true;

    try {
      this.jobId = await enqueueSync({
        accountId: this.recordId
      });

      this.dispatchEvent(
        new ShowToastEvent({
          title: "Synchronization queued",
          message: `Salesforce job ${this.jobId} was queued successfully.`,
          variant: "success"
        })
      );
    } catch (error) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Synchronization failed",
          message: this.getErrorMessage(error),
          variant: "error"
        })
      );
    } finally {
      this.isLoading = false;
    }
  }

  getErrorMessage(error) {
    return (
      error?.body?.message || error?.message || "An unexpected error occurred."
    );
  }
}
