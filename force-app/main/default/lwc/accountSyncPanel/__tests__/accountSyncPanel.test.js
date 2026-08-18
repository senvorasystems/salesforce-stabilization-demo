import { createElement } from "lwc";
import AccountSyncPanel from "c/accountSyncPanel";
import enqueueSync from "@salesforce/apex/AccountSyncController.enqueueSync";

jest.mock(
  "@salesforce/apex/AccountSyncController.enqueueSync",
  () => ({
    default: jest.fn()
  }),
  { virtual: true }
);

const flushPromises = async () => {
  await Promise.resolve();
  await Promise.resolve();
};

describe("c-account-sync-panel", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }

    jest.clearAllMocks();
  });

  it("queues the current Account and displays the job id", async () => {
    enqueueSync.mockResolvedValue("707000000000001AAA");

    const element = createElement("c-account-sync-panel", {
      is: AccountSyncPanel
    });

    element.recordId = "001000000000001AAA";
    document.body.appendChild(element);

    const button = element.shadowRoot.querySelector("lightning-button");

    button.click();

    expect(enqueueSync).toHaveBeenCalledTimes(1);
    expect(enqueueSync).toHaveBeenCalledWith({
      accountId: "001000000000001AAA"
    });

    await flushPromises();

    expect(element.shadowRoot.textContent).toContain("Queued Job:");

    expect(element.shadowRoot.textContent).toContain("707000000000001AAA");

    expect(element.shadowRoot.querySelector("lightning-spinner")).toBeNull();
  });

  it("shows a loading state while synchronization is pending", async () => {
    let resolveRequest;

    enqueueSync.mockImplementation(
      () =>
        new Promise((resolve) => {
          resolveRequest = resolve;
        })
    );

    const element = createElement("c-account-sync-panel", {
      is: AccountSyncPanel
    });

    element.recordId = "001000000000001AAA";
    document.body.appendChild(element);

    const button = element.shadowRoot.querySelector("lightning-button");

    button.click();

    await Promise.resolve();

    expect(
      element.shadowRoot.querySelector("lightning-spinner")
    ).not.toBeNull();

    resolveRequest("707000000000002AAA");

    await flushPromises();

    expect(element.shadowRoot.querySelector("lightning-spinner")).toBeNull();
  });

  it("handles an Apex error without displaying a queued job", async () => {
    enqueueSync.mockRejectedValue({
      body: {
        message: "Integration service unavailable"
      }
    });

    const element = createElement("c-account-sync-panel", {
      is: AccountSyncPanel
    });

    element.recordId = "001000000000001AAA";

    const toastHandler = jest.fn();

    element.addEventListener("lightning__showtoast", toastHandler);

    document.body.appendChild(element);

    const button = element.shadowRoot.querySelector("lightning-button");

    button.click();

    await flushPromises();

    expect(enqueueSync).toHaveBeenCalledWith({
      accountId: "001000000000001AAA"
    });

    expect(toastHandler).toHaveBeenCalledTimes(1);

    expect(element.shadowRoot.textContent).not.toContain("Queued Job:");

    expect(element.shadowRoot.querySelector("lightning-spinner")).toBeNull();
  });
});
