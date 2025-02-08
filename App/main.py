import tkinter as tk
from tkinter import messagebox
import requests
import json
from run_command import *

PINATA_API_KEY = ""
PINATA_SECRET_API_KEY = ""

def upload_to_ipfs(file_url):
    url = "https://api.pinata.cloud/pinning/pinJSONToIPFS"
    headers = {
        "pinata_api_key": PINATA_API_KEY,
        "pinata_secret_api_key": PINATA_SECRET_API_KEY,
        "Content-Type": "application/json"
    }
    data = {
        "pinataContent": {"image": file_url},
        "pinataMetadata": {"name": "Event_NFT_Image"}
    }
    response = requests.post(url, headers=headers, json=data)
    if response.status_code == 200:
        return response.json()["IpfsHash"]
    else:
        show_custom_dialog("IPFS Error", "Failed to upload image to IPFS.")
        return None

def upload_metadata_to_ipfs(metadata):
    url = "https://api.pinata.cloud/pinning/pinJSONToIPFS"
    headers = {
        "pinata_api_key": PINATA_API_KEY,
        "pinata_secret_api_key": PINATA_SECRET_API_KEY,
        "Content-Type": "application/json"
    }
    response = requests.post(url, headers=headers, json=metadata)
    if response.status_code == 200:
        return response.json()["IpfsHash"]
    else:
        show_custom_dialog("IPFS Error", "Failed to upload metadata to IPFS.")
        return None

def show_custom_dialog(title, message):
    dialog = tk.Toplevel(root)
    dialog.title(title)

    text_widget = tk.Text(dialog, wrap="word", width=50, height=10)
    text_widget.insert(tk.END, message)
    text_widget.config(state=tk.DISABLED)

    text_widget.pack(padx=10, pady=10)

    # Make text selectable
    text_widget.config(state=tk.NORMAL)
    text_widget.bind("<Button-1>", lambda e: text_widget.focus_set())
    text_widget.config(state=tk.DISABLED)

    close_button = tk.Button(dialog, text="OK", command=dialog.destroy)
    close_button.pack(pady=5)

def create_event():
    create_window = tk.Toplevel(root)
    create_window.title("Create Event")

    tk.Label(create_window, text="Event Name:").grid(row=0, column=0, pady=5, padx=5)
    event_name = tk.Entry(create_window, width=30)
    event_name.grid(row=0, column=1, pady=5, padx=5)

    tk.Label(create_window, text="Number of Tickets:").grid(row=1, column=0, pady=5, padx=5)
    num_tickets = tk.Entry(create_window, width=30)
    num_tickets.grid(row=1, column=1, pady=5, padx=5)

    tk.Label(create_window, text="Location:").grid(row=2, column=0, pady=5, padx=5)
    location = tk.Entry(create_window, width=30)
    location.grid(row=2, column=1, pady=5, padx=5)

    tk.Label(create_window, text="Date of Event (YYYY-MM-DD):").grid(row=3, column=0, pady=5, padx=5)
    event_date = tk.Entry(create_window, width=30)
    event_date.grid(row=3, column=1, pady=5, padx=5)

    tk.Label(create_window, text="Link of NFT image:").grid(row=4, column=0, pady=5, padx=5)
    event_img = tk.Entry(create_window, width=30)
    event_img.grid(row=4, column=1, pady=5, padx=5)

    tk.Label(create_window, text="Your private key:").grid(row=5, column=0, pady=5, padx=5)
    event_key = tk.Entry(create_window, width=30)
    event_key.grid(row=5, column=1, pady=5, padx=5)

    def submit_event():
        name = event_name.get()
        tickets = num_tickets.get()
        loc = location.get()
        date = event_date.get()
        nft_img = event_img.get()
        private_key = event_key.get()

        if not name or not tickets or not loc or not date or not nft_img:
            show_custom_dialog("Error", "Please fill all fields!")
            return
        try:
            tickets = int(tickets)
            if tickets <= 0:
                raise ValueError
        except ValueError:
            show_custom_dialog("Error", "Number of Tickets must be a positive integer!")
            return
        image_cid = upload_to_ipfs(nft_img)
        if not image_cid:
            return
        ipfs_image_url = f"https://gateway.pinata.cloud/ipfs/{image_cid}"
        metadata = {
            "name": name,
            "description": f"Event '{name}' at {loc} on {date}",
            "image": ipfs_image_url,
            "attributes": [
                {"trait_type": "Number of Tickets", "value": tickets},
                {"trait_type": "Location", "value": loc},
                {"trait_type": "Date", "value": date}
            ]
        }

        metadata_cid = upload_metadata_to_ipfs(metadata)
        if not metadata_cid:
            return
        
        metadata_url = f"https://gateway.pinata.cloud/ipfs/{metadata_cid}"
        show_custom_dialog("Event Created", f"Event '{name}' created!\nNFT Metadata CID: {metadata_cid}\nMetadata URL: {metadata_url}")

        # ------------------------------------------------------------- Deploy Contract
        constructor_args = f'"{loc}" "{name}" "100" "{metadata_cid}" ""'
        command = f'forge create ./src/TicketMetadata.sol:TicketNFTMetadata --private-key {private_key} --broadcast --constructor-args {constructor_args}'

        stdout, stderr = run_command(command)
        if stderr:
            show_custom_dialog("Error", f"Contract deployment failed: {stderr}")
            return

        show_custom_dialog("Success", f"Contract deployed successfully!\n{stdout}")
        create_window.destroy()

    submit_button = tk.Button(create_window, text="Create Event", command=submit_event)
    submit_button.grid(row=5, columnspan=2, pady=10)

def get_ticket_for_event():
    ticket_window = tk.Toplevel(root)
    ticket_window.title("Get Ticket for Event")

    tk.Label(ticket_window, text="Contract Address:").grid(row=0, column=0, pady=5, padx=5)
    contract_address = tk.Entry(ticket_window, width=30)
    contract_address.grid(row=0, column=1, pady=5, padx=5)

    tk.Label(ticket_window, text="Wallet Address:").grid(row=1, column=0, pady=5, padx=5)
    wallet_address = tk.Entry(ticket_window, width=30)
    wallet_address.grid(row=1, column=1, pady=5, padx=5)

    tk.Label(ticket_window, text="Private Key:").grid(row=2, column=0, pady=5, padx=5)
    e_private_key = tk.Entry(ticket_window, width=30)
    e_private_key.grid(row=2, column=1, pady=5, padx=5)

    def submit_ticket_request():
        contract_address_value = contract_address.get()
        wallet_address_value = wallet_address.get()
        private_key = e_private_key.get()

        if not contract_address_value or not wallet_address_value:
            show_custom_dialog("Error", "Please fill both Contract Address and Wallet Address!")
            return
        if len(contract_address_value) != 42 or len(wallet_address_value) != 42:
            show_custom_dialog("Error", "Both addresses must be 42 characters long (including the '0x').")
            return

        show_custom_dialog("Success", f"Contract Address: {contract_address_value}\nWallet Address: {wallet_address_value} and private key : {private_key}")

        command = f'cast send {contract_address_value} "mint()" --from {wallet_address_value} --private-key {private_key}'

        stdout, stderr = run_command(command)
        if stderr:
            show_custom_dialog("Error", f"Erreur dans la récuperation du billet: {stderr}")
            return
        show_custom_dialog("Success", f"Billet recuperer avec succes!\n{stdout}")
        ticket_window.destroy()

    submit_button = tk.Button(ticket_window, text="Get Ticket", command=submit_ticket_request)
    submit_button.grid(row=2, columnspan=2, pady=10)


def get_qr_code():
    show_custom_dialog("Get QR Code", "Fonction pour le QR Code.")

root = tk.Tk()
root.title("Event Management")

btn_create_event = tk.Button(root, text="Create Event", width=20, command=create_event)
btn_create_event.pack(pady=10)

btn_get_ticket = tk.Button(root, text="Get Ticket for Event", width=20, command=get_ticket_for_event)
btn_get_ticket.pack(pady=10)

btn_get_qr = tk.Button(root, text="Get your QR Code", width=20, command=get_qr_code)
btn_get_qr.pack(pady=10)

root.mainloop()
