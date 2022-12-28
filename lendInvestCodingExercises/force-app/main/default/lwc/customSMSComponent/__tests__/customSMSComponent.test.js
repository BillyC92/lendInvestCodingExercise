import { createElement } from 'lwc';
import CustomSMSComponent from 'c/customSMSComponent';


function testSetup() {

    const mockClickHandler = jest.fn();

    // Create initial element
    const element = createElement('c-custom-sms-component', {
        is: CustomSMSComponent
    });

    element.addEventListener('click', mockClickHandler);
    document.body.appendChild(element);

    // Get child elements
    const buttonElement = element.shadowRoot.querySelector('lightning-button');

    return { element, buttonElement, mockClickHandler };
}

describe('c-custom-sms-component', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('Click event is called', () => {

        const { buttonElement, mockClickHandler } = testSetup();

        buttonElement.click();

        expect(mockClickHandler).toHaveBeenCalled();

    });
});